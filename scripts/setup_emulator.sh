#!/bin/sh
cd `dirname $0`
cd ../firebase
if ls ~/.cache/firebase/emulators/cloud-firestore-emulator-v*.jar 1> /dev/null 2>&1; then
  echo 'emulators already installed.'
else
  firebase setup:emulators:firestore
fi