#!/bin/sh
cd `dirname $0`
cd ../firebase
firebase emulators:exec "../scripts/unittest.sh" --only firestore