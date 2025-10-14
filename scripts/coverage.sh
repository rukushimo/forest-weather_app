#!/bin/bash

# Run tests with coverage
flutter test --coverage

# Remove generated files from coverage
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/main.dart' \
  -o coverage/lcov.info

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html