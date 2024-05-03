#!/bin/bash

if [ ! -f go.mod ]; then
    echo "go.mod not found"
    exit 1
fi

if [ ! -f go.sum ]; then
    echo "go.sum not found"
    exit 1
fi

# run go download with retries
NR_RETRIES=5
RETRY_DELAY=5
for i in $(seq 1 $NR_RETRIES); do
    go mod download && break
    if [ $i -eq $NR_RETRIES ]; then
        echo "Failed to download dependencies after $NR_RETRIES retries"
        exit 1
    fi
    echo "Failed to download dependencies, retrying in $RETRY_DELAY seconds"
    sleep $RETRY_DELAY
done

exit 0
