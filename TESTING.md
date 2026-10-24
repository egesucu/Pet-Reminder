# Running all tests

Select the **Pet Reminder** scheme and **Pet Reminder** test plan, choose an iPhone
or iOS simulator, and use Product → Test (⌘U).

The plan runs the app-hosted `Pet ReminderTests` target. Its Sources phase references
all package test files directly, alongside the app tests. No test source is copied,
no package suite is omitted, and there are no test-selection filters or opt-in
flags. Hosting the entire suite in the app allows the same plan to run on physical
devices, where tool-hosted Swift package test targets are unavailable.

Individual package test targets remain available for focused simulator runs. They
are not separate entries in the main plan because that would run their tests twice
and prevent the main plan from running on an iPhone.

From the repository root:

```sh
# Simulator: replace the destination identifier.
xcodebuild test -project 'Pet Reminder.xcodeproj' -scheme 'Pet Reminder' \
  -testPlan 'Pet Reminder' -destination 'platform=iOS Simulator,id=SIMULATOR_ID' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO

# Physical iPhone: use normal app signing.
xcodebuild test -project 'Pet Reminder.xcodeproj' -scheme 'Pet Reminder' \
  -testPlan 'Pet Reminder' -destination 'platform=iOS,id=DEVICE_ID' \
  -parallel-testing-enabled NO
```

EventKit adapter tests always run. They construct unsaved EventKit objects and use
mock saves; they do not verify device calendar persistence or system permission
prompts. Pure Events tests use fixed dates, explicit time zones, and fake
operations, avoiding calendar account and synchronization dependencies.

After adding a package test file, add a reference to that file to the app-hosted
target's Sources phase. Run `python3 ci_scripts/check_test_plan.py` to check that
all package test files remain included and that the main plan has no exclusions.
