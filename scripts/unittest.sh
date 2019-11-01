#!/bin/sh
cd `dirname $0`
cd ../
PROJECT_NAME='FireSnapshot'
set -o pipefail && env "NSUnbufferedIO=YES" xcodebuild "-workspace" "${PROJECT_NAME}.xcworkspace" "-scheme" "${PROJECT_NAME}" "build" "test" "-destination" "name=iPhone 11 Pro" | xcpretty "--color"