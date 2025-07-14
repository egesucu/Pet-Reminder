#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Pet Reminder
#
#  Created by Ege Sucu on 20.09.2023.
#  Copyright © 2023 Ege Sucu. All rights reserved.

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
