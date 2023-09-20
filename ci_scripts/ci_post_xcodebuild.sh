#!/bin/sh

#  ci_post_xcodebuild.sh
#  Pet Reminder
#
#  Created by Ege Sucu on 20.09.2023.
#  Copyright © 2023 Softhion. All rights reserved.
set -e

# Linting all files.
swiftlint --fix

echo("Linted All Files")
