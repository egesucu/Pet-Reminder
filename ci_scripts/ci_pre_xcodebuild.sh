#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Pet Reminder
#
#  Created by Ege Sucu on 20.09.2023.
#  Copyright © 2023 Ege Sucu. All rights reserved.

set -eu

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

repository_path="${CI_PRIMARY_REPOSITORY_PATH:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
python3 "$repository_path/ci_scripts/check_modules.py"
python3 "$repository_path/ci_scripts/check_test_plan.py"
python3 -m unittest discover -s "$repository_path/ci_scripts" -p 'test_module_boundaries.py'
