#!/bin/bash

if [ "$RUBY_VERSION" == "" ]; then
  echo "RUBY_VERSION environment variable is required!"
  exit 1
fi
echo "Ruby Version: $RUBY_VERSION"
chruby $RUBY_VERSION

echo "Installing Go & Running unit tests..."
COVERAGE=true bundle exec rake --trace go spec:unit ci:publish_coverage_report
