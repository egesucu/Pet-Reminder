#!/bin/zsh.

#  ci_post_clone.sh
#  Pet Reminder
#
#  Created by Ege Sucu on 20.09.2023.
#  Copyright © 2023 Softhion. All rights reserved.

# Installs swiftlint from homebrew
set -e

brew install swiftlint

echo("Did you read me?")
