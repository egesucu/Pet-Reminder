#!/usr/bin/env python3
"""Check catalog completeness, translation review state and argument safety."""
from collections import Counter
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
LANGUAGES = ('en', 'de', 'es', 'fr', 'it', 'tr')
FORMAT = re.compile(r'%(?:\d+\$)?[-+#0 ]*\d*(?:\.\d+)?(?:ll|l|h)?[@diufgs]')
TOKENS = re.compile(r'\$\{\w+\}')


def units(node, path=()):
    if not isinstance(node, dict):
        return
    if 'stringUnit' in node:
        yield path, node['stringUnit']
    for name, value in node.items():
        yield from units(value, path + (name,))


def arguments(text):
    # Argument positions may change with sentence order; their types must match.
    return Counter(re.sub(r'^%\d+\$', '%', token) for token in FORMAT.findall(text))


def inspect_catalog(catalog):
    errors = []
    keys_by_case = {}
    for key, entry in catalog['strings'].items():
        folded_key = key.casefold()
        if folded_key in keys_by_case:
            errors.append(f'{key!r}: differs only in case from {keys_by_case[folded_key]!r}')
        else:
            keys_by_case[folded_key] = key
        if entry.get('extractionState') == 'stale':
            errors.append(f'{key!r}: stale entry')
        if entry.get('shouldTranslate') is False:
            continue
        for language in LANGUAGES:
            localization = entry.get('localizations', {}).get(language, {})
            leaves = list(units(localization))
            if not leaves:
                errors.append(f'{key!r}/{language}: missing translation')
            plural = localization.get('variations', {}).get('plural')
            if plural is not None and 'other' not in plural:
                errors.append(f'{key!r}/{language}: plural missing other branch')
            for path, unit in leaves:
                value = unit.get('value', '')
                if not value.strip() or unit.get('state') != 'translated':
                    errors.append(f'{key!r}/{language}/{"/".join(path)}: empty or unreviewed translation')
                if 'variableName' in value:
                    errors.append(f'{key!r}/{language}: unresolved format placeholder')
                expected, actual = arguments(key), arguments(value)
                # Singular/zero messages may spell out the only count argument.
                spelled_count = path[-1:] in [('one',), ('zero',)] and expected == Counter({'%lld': 1}) and not actual
                if expected != actual and not spelled_count:
                    errors.append(f'{key!r}/{language}: format arguments differ')
                if Counter(TOKENS.findall(key)) != Counter(TOKENS.findall(value)):
                    errors.append(f'{key!r}/{language}: shortcut parameter tokens differ')
    return errors


def check(root=ROOT):
    errors = []
    for path in (root / 'Pet Reminder').rglob('*.xcstrings'):
        catalog = json.loads(path.read_text())
        errors.extend(f'{path.relative_to(root)}: {error}' for error in inspect_catalog(catalog))
    shared = json.loads((root / 'Pet Reminder/Packages/Shared/Sources/Shared/Localizable.xcstrings').read_text())['strings']
    # Plain bundle-aware keys are checked directly. Interpolated keys are verified
    # by runtime tests, since Swift determines their argument types.
    references = re.compile(r'(?:SharedStrings\.resource\(|LocalizedStringResource\(|String\(localized:\s*)"([^"\\]*)"')
    for path in (root / 'Pet Reminder/Packages').rglob('*.swift'):
        if 'Tests' in path.parts:
            continue
        for key in references.findall(path.read_text()):
            if key not in shared:
                errors.append(f'{path.relative_to(root)}: missing Shared key {key!r}')
    return errors


if __name__ == '__main__':
    errors = check()
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        sys.exit(1)
    for language in LANGUAGES:
        print(f'{language}: 100% catalog coverage; all translations reviewed')
    print('No stale entries, missing Shared keys, or mismatched format/shortcut arguments.')
