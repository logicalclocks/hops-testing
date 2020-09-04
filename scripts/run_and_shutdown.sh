#!/bin/bash
set -e
set -x

BASE_PATH=$1
PLATFORM=$2
NAME=$3

EXIT_CODE=0
CLEAN_EXIT_CODE=0
bash "${BASE_PATH}/scripts/run_test.sh" $PLATFORM || EXIT_CODE=$?
bash "${BASE_PATH}/scripts/shutdown.sh" $NAME || CLEAN_EXIT_CODE=$?


if [ $EXIT_CODE -ne 0 ]; then
	exit $EXIT_CODE;
else
	exit $CLEAN_EXIT_CODE;
fi
