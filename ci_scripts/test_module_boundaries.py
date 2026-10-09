import unittest
from check_modules import inspect_imports


class ImportBoundaryTests(unittest.TestCase):
    def test_feature_cannot_import_app_or_undeclared_peer(self):
        errors = inspect_imports('@testable import Pet_Reminder\nimport Events', 'Pets', {'Shared'})
        self.assertEqual(len(errors), 2)

    def test_intro_only_uses_shared_modules(self):
        dependencies = {"Shared", "SharedUI"}
        self.assertEqual(inspect_imports("import Shared\nimport SharedUI", "Intro", dependencies), [])
        for module in ("Reminders", "Pets", "AppIntents", "CoreSpotlight", "Pet_Reminder"):
            self.assertTrue(inspect_imports(f"import {module}", "Intro", dependencies))

    def test_preview_import_requires_debug_including_else_branches(self):
        self.assertEqual(inspect_imports('#if DEBUG\nimport PreviewSupport\n#endif', 'Pets', {'PreviewSupport'}), [])
        self.assertTrue(inspect_imports('#if DEBUG\n#else\nimport PreviewSupport\n#endif', 'Pets', {'PreviewSupport'}))
        self.assertTrue(inspect_imports('import PreviewSupport', 'Pets', {'PreviewSupport'}))

    def test_nested_debug_condition_and_qualified_imports(self):
        self.assertEqual(inspect_imports('#if DEBUG\n#if canImport(SwiftUI)\nimport PreviewSupport\n#endif\n#endif', 'Pets', {'PreviewSupport'}), [])
        self.assertTrue(inspect_imports('@preconcurrency import struct Events.EventCalendar', 'Pets', {'Shared'}))


if __name__ == '__main__':
    unittest.main()
