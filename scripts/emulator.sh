#!/bin/sh
cd `dirname $0`
cd ../firebase
firebase emulators:start --only firestore