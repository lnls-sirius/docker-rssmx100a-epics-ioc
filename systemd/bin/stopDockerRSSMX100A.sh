#!/usr/bin/env bash

set -u

if [ -z "$RSSMX100A_INSTANCE" ]; then
    echo "RSSMX100A_INSTANCE environment variable is not set." >&2
    exit 1
fi

/usr/bin/docker stop \
    rssmx100a-epics-ioc-${RSSMX100A_INSTANCE}
