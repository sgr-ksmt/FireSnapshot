#!/bin/sh
cd `dirname $0`
./setup_emulator.sh

cd ../firebase
firebase emulators:start --only firestore