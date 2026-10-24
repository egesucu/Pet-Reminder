#!/usr/bin/env python3
"""Validate the deliberately literal local-package graph and Swift import boundaries."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {
    'Shared': set(),
    'SharedUI': {'Shared'},
    'PetCare': {'Shared'},
    'Reminders': {'Shared'},
    'Pets': {'Shared', 'SharedUI', 'PetCare', 'Reminders', 'PreviewSupport'},
    'Events': {'Shared', 'SharedUI'},
    'VetFinder': {'Shared', 'SharedUI'},
    'Intro': {'Shared', 'SharedUI'},
    'Settings': {'Shared', 'SharedUI', 'Reminders', 'PreviewSupport'},
    'PreviewSupport': {'Shared', 'SharedUI'},
}
IMPORT = re.compile(r'^\s*(?:(?:@testable|@preconcurrency|public|internal|private|package)\s+)*import\s+(?:struct\s+|class\s+|enum\s+|protocol\s+|func\s+|var\s+|let\s+|typealias\s+)?(\w+)')


def inspect_imports(source, owner, dependencies):
    errors = []
    conditions = []
    for number, line in enumerate(source.splitlines(), 1):
        directive = line.strip()
        if directive.startswith('#if '):
            conditions.append(directive == '#if DEBUG')
        elif directive.startswith('#elseif ') or directive == '#else':
            if conditions:
                conditions[-1] = False
        elif directive == '#endif':
            if conditions:
                conditions.pop()
        match = IMPORT.match(line)
        if not match:
            continue
        imported = match[1]
        if imported == 'Pet_Reminder' or (owner in {'Pets', 'Events', 'VetFinder', 'Settings', 'Intro'} and imported in {'AppIntents', 'CoreSpotlight'}):
            errors.append(f'{number}: {owner} imports app-owned integration {imported}')
        if imported in ALLOWED and imported != owner and imported not in dependencies:
            errors.append(f'{number}: {owner} imports undeclared module {imported}')
        if imported == 'PreviewSupport' and not any(conditions):
            errors.append(f'{number}: PreviewSupport import must be inside #if DEBUG')
    return errors


def check(root=ROOT):
    packages = root / 'Pet Reminder/Packages'
    errors = []
    graph = {}
    manifests = list(packages.glob('*/Package.swift'))
    names = {p.parent.name for p in manifests}
    if names != set(ALLOWED) | {'ModuleTests'}:
        errors.append(f'Packages do not match the documented graph: {sorted(names ^ (set(ALLOWED) | {"ModuleTests"}))}')
    for owner in ALLOWED:
        package = packages / owner
        path = package / 'Package.swift'
        if not path.exists():
            continue
        manifest = path.read_text()
        local = re.findall(r'\.package\(path: "\.\./(\w+)"\)', manifest)
        if len(local) != len(re.findall(r'\.package\(', manifest)):
            errors.append(f'{owner}: package dependencies must be explicit local paths')
        graph[owner] = set(local)
        if set(local) - ALLOWED[owner]:
            errors.append(f'{owner}: forbidden package dependencies {sorted(set(local) - ALLOWED[owner])}')
        declarations = re.findall(r'\.target\(\s*name:\s*"(\w+)",\s*dependencies:\s*(\[[^\]]*\])', manifest)
        if len(declarations) != 1 or declarations[0][0] != owner:
            errors.append(f'{owner}: must declare one production target with the package name')
            continue
        raw = declarations[0][1]
        products = re.findall(r'\.product\(name: "(\w+)", package: "(\w+)"\)', raw)
        remainder = re.sub(r'\.product\(name: "\w+", package: "\w+"\)', '', raw)
        if re.sub(r'[\[\],\s]', '', remainder):
            errors.append(f'{owner}: target dependencies must be explicit package products')
        dependencies = {product for product, _ in products}
        if dependencies != set(local) or any(name.lower() != identity for name, identity in products):
            errors.append(f'{owner}: product dependencies must match declared local packages')
        directory = package / 'Sources' / owner
        if not list(directory.rglob('*.swift')):
            errors.append(f'{owner}: target has no Swift sources')
        for swift in directory.rglob('*.swift'):
            errors.extend(f'{swift.relative_to(root)}:{error}' for error in inspect_imports(swift.read_text(), owner, dependencies))
    for path in (root / 'Pet Reminder').rglob('*.swift'):
        if packages in path.parents:
            continue
        for error in inspect_imports(path.read_text(), 'App', set(ALLOWED)):
            errors.append(f'{path.relative_to(root)}:{error}')
        if any(part in {'Pets', 'AddPet', 'PetChange', 'Events', 'VetFinder', 'Settings', 'Intro'} for part in path.relative_to(root / 'Pet Reminder').parts[:-1]):
            errors.append(f'{path.relative_to(root)}: extracted feature remains in app source membership')
    consumer_tests = packages / 'ModuleTests/Tests'
    for path in consumer_tests.rglob('*.swift'):
        if re.search(r'@testable\s+import', path.read_text()):
            errors.append(f'{path.relative_to(root)}: public API consumers must not use @testable imports')
    # Check cycles independently, even if a future allowlist is edited incorrectly.
    def visit(node, chain):
        if node in chain:
            errors.append('Dependency cycle: ' + ' -> '.join(chain + [node]))
            return
        for dependency in graph.get(node, set()):
            visit(dependency, chain + [node])
    for node in graph:
        visit(node, [])
    return errors


if __name__ == '__main__':
    violations = check()
    if violations:
        print('\n'.join(violations), file=sys.stderr)
        sys.exit(1)
    print('Module graph, source ownership, and preview import checks passed.')
