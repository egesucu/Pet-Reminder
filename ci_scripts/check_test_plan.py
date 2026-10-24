#!/usr/bin/env python3
"""Audit the complete app-hosted test plan without requiring Xcode."""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
HOST = 'Pet ReminderTests'


def read_project(path):
    # project.xcproj permits trailing commas. Preserve all quoted string contents.
    source = re.sub(r'("(?:\\.|[^"\\])*")|,(?=\s*[}\]])',
                    lambda match: match[1] or '', path.read_text())
    return json.loads(source)


def hosted_sources(project, root):
    included = set()

    def visit(entries, parent):
        for entry in entries:
            path = parent / entry.get('path', '')
            if HOST in entry.get('target-membership', []):
                exclusions = [item for exception in entry.get('membership-exceptions', [])
                              if exception.get('target') == HOST
                              for item in exception.get('exclusions', [])]
                candidates = path.rglob('*.swift') if entry.get('kind') == 'folder' else [path]
                for candidate in candidates:
                    relative = candidate.relative_to(path).as_posix() if candidate != path else path.name
                    if candidate.suffix == '.swift' and not any(
                        relative == excluded or relative.startswith(excluded.rstrip('/') + '/')
                        for excluded in exclusions
                    ):
                        included.add(candidate)
            visit(entry.get('children', []), path)

    visit(project.get('files', []), root)
    return included


def check(root=ROOT):
    project = read_project(root / 'Pet Reminder.xcodeproj/project.xcproj')
    plan = json.loads((root / 'Pet Reminder.xctestplan').read_text())
    errors = []
    targets = plan.get('testTargets', [])
    host = next((target for target in project.get('targets', []) if target.get('name') == HOST), {})
    if (len(targets) != 1 or targets[0].get('target', {}).get('name') != HOST
            or targets[0].get('target', {}).get('identifier') != host.get('id')):
        errors.append('Main plan must run the complete app-hosted Pet ReminderTests target.')
    if host.get('test-host-target') != 'Pet Reminder' or 'compile-sources' not in host.get('build-phases', []):
        errors.append('Missing app-hosted test target or compile-sources phase.')

    def audit_options(value):
        if isinstance(value, dict):
            for key, child in value.items():
                if key in ('selectedTests', 'skippedTests') and child:
                    errors.append(f'Test plan contains a {key} filter.')
                if key in ('enabled', 'isEnabled') and child is False:
                    errors.append('Test plan contains a disabled entry.')
                audit_options(child)
        elif isinstance(value, list):
            for child in value:
                audit_options(child)

    audit_options(plan)
    included = hosted_sources(project, root)
    files = sorted((root / 'Pet Reminder/Packages').glob('*/Tests/**/*.swift'))
    app_files = sorted((root / HOST).rglob('*.swift'))
    for path in files + app_files:
        relative = path.relative_to(root)
        if path not in included:
            errors.append(f'Test file is missing from hosted Sources: {relative}')
        if re.search(r'\.enabled\(if:|\.disabled\(|XCTSkip', path.read_text()):
            errors.append(f'Conditional test gate found: {relative}')
    return errors, len(files)


if __name__ == '__main__':
    try:
        errors, count = check()
    except (OSError, ValueError) as error:
        print(f'Unable to audit test plan: {error}', file=sys.stderr)
        sys.exit(1)
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        sys.exit(1)
    print(f'Complete hosted plan: {count} package test files, no exclusions or conditional gates.')
