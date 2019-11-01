#!/bin/sh
cd `dirname $0`
./setup_emulator.sh

cd ../firebase
firebase emulators:exec "`pwd`/../scripts/unittest.sh" --only firestore