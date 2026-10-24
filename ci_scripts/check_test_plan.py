#!/usr/bin/env python3
"""Audit the complete app-hosted test plan without requiring Xcode."""
import json
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parent.parent
project = (root / 'Pet Reminder.xcodeproj/project.pbxproj').read_text()
plan = json.loads((root / 'Pet Reminder.xctestplan').read_text())
errors = []
targets = plan.get('testTargets', [])
if len(targets) != 1 or targets[0].get('target', {}).get('name') != 'Pet ReminderTests':
    errors.append('Main plan must run the complete app-hosted Pet ReminderTests target.')


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
refs = dict(re.findall(r'(\w{24}) /\* .*? \*/ = \{isa = PBXFileReference;[^\n]*?path = "([^"]+\.swift)";', project))
build_refs = dict(re.findall(r'(\w{24}) /\* .*? \*/ = \{isa = PBXBuildFile; fileRef = (\w{24})', project))
phase = re.search(r'72C446402C9B6BBC003B1DE7 /\* Sources \*/ = \{(.*?)\n\t\t\};', project, re.S)
if not phase:
    errors.append('Missing app-hosted test Sources phase.')
    included = set()
else:
    included = {refs.get(build_refs.get(identifier)) for identifier in re.findall(r'\b\w{24}\b', phase.group(1))}
files = sorted((root / 'Pet Reminder/Packages').glob('*/Tests/**/*.swift'))
for path in files:
    relative = str(path.relative_to(root))
    if relative not in included:
        errors.append(f'Package test file is missing from hosted Sources: {relative}')
    if re.search(r'\.enabled\(if:|\.disabled\(|XCTSkip', path.read_text()):
        errors.append(f'Conditional test gate found: {relative}')
for path in (root / 'Pet ReminderTests').rglob('*.swift'):
    if re.search(r'\.enabled\(if:|\.disabled\(|XCTSkip', path.read_text()):
        errors.append(f'Conditional test gate found: {path.relative_to(root)}')
if errors:
    print('\n'.join(errors), file=sys.stderr)
    sys.exit(1)
print(f'Complete hosted plan: {len(files)} package test files, no exclusions or conditional gates.')
