#!/bin/sh
cd `dirname $0`
cd ../firebase
# VERSION=1.8.4
# if [[ ! -e ~/.cache/firebase/emulators/cloud-firestore-emulator-v$VERSION.jar ]]; then
  firebase setup:emulators:firestore
# else
#   echo 'emulators already installed.'
# fi
firebase emulators:exec "`pwd`/../scripts/unittest.sh" --only firestore