import json
from pathlib import Path
import tempfile
import unittest

from check_test_plan import check, read_project


class TestPlanTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.package_tests = 'Pet Reminder/Packages/Example/Tests'
        self.project = {
            'files': [
                {'kind': 'folder', 'path': self.package_tests, 'target-membership': ['Pet ReminderTests']},
                {'kind': 'folder', 'path': 'Pet ReminderTests', 'target-membership': ['Pet ReminderTests']},
            ],
            'targets': [{'name': 'Pet ReminderTests', 'id': 'host-id',
                         'test-host-target': 'Pet Reminder', 'build-phases': ['compile-sources']}],
        }
        self.plan = {'testTargets': [{'target': {'name': 'Pet ReminderTests', 'identifier': 'host-id'}}]}
        for source in (self.package_tests + '/ExampleTests/ExampleTests.swift', 'Pet ReminderTests/AppTests.swift'):
            path = self.root / source
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('import Testing\n')
        (self.root / 'Pet Reminder.xcodeproj').mkdir()

    def run_check(self):
        (self.root / 'Pet Reminder.xcodeproj/project.xcproj').write_text(json.dumps(self.project))
        (self.root / 'Pet Reminder.xctestplan').write_text(json.dumps(self.plan))
        return check(self.root)[0]

    def test_reads_current_format_without_pbxproj(self):
        self.assertEqual(self.run_check(), [])

    def test_trailing_commas_preserve_string_contents(self):
        path = self.root / 'Pet Reminder.xcodeproj/project.xcproj'
        path.write_text('{"values": ["literal,}", "escaped\\\"comma,]",],}')
        self.assertEqual(read_project(path), {'values': ['literal,}', 'escaped"comma,]']})

    def test_missing_membership_is_rejected(self):
        for entry in self.project['files']:
            with self.subTest(path=entry['path']):
                entry['target-membership'] = []
                self.assertTrue(any('missing from hosted Sources' in error for error in self.run_check()))
                entry['target-membership'] = ['Pet ReminderTests']

    def test_folder_and_file_exclusions_are_rejected(self):
        for exclusion in ('ExampleTests', 'ExampleTests/ExampleTests.swift'):
            with self.subTest(exclusion=exclusion):
                self.project['files'][0]['membership-exceptions'] = [
                    {'target': 'Pet ReminderTests', 'exclusions': [exclusion]}
                ]
                self.assertTrue(any('missing from hosted Sources' in error for error in self.run_check()))

    def test_other_target_exclusions_do_not_remove_hosted_tests(self):
        self.project['files'][0]['membership-exceptions'] = [
            {'target': 'Pet Reminder', 'exclusions': ['ExampleTests']}
        ]
        self.assertEqual(self.run_check(), [])

    def test_plan_filters_and_disabled_targets_are_rejected(self):
        for option, value in (('skippedTests', ['ExampleTests']), ('selectedTests', ['AppTests']), ('enabled', False)):
            with self.subTest(option=option):
                self.plan['testTargets'][0][option] = value
                self.assertTrue(self.run_check())
                del self.plan['testTargets'][0][option]

    def test_wrong_target_identity_and_missing_host_are_rejected(self):
        self.plan['testTargets'][0]['target']['identifier'] = 'other-id'
        self.assertTrue(self.run_check())
        self.plan['testTargets'][0]['target']['identifier'] = 'host-id'
        del self.project['targets'][0]['test-host-target']
        self.assertTrue(self.run_check())

    def test_conditional_gate_is_rejected(self):
        (self.root / self.package_tests / 'ExampleTests/ExampleTests.swift').write_text('@Test(.disabled())\n')
        self.assertTrue(any('Conditional test gate' in error for error in self.run_check()))


if __name__ == '__main__':
    unittest.main()
