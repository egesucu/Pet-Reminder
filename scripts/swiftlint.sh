if which swiftlint > /dev/null; then
  swiftlint --fix
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
