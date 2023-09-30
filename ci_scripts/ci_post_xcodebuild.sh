#!/bin/sh

#  ci_post_xcodebuild.sh
#  Pet Reminder
#
#  Created by Ege Sucu on 20.09.2023.
#  Copyright © 2023 Ege Sucu. All rights reserved.

# Linting all files.
set -e
swiftlint --fix --strict $CI_PRIMARY_REPOSITORY_PATH
