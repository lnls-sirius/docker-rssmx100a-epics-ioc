#!/usr/bin/env bash

set -u

if [ -z "$RSSMX100A_INSTANCE" ]; then
    echo "RSSMX100A_INSTANCE environment variable is not set." >&2
    exit 1
fi

export RSSMX100A_CURRENT_PV_AREA_PREFIX=RSSMX100A_${RSSMX100A_INSTANCE}_PV_AREA_PREFIX
export RSSMX100A_CURRENT_PV_DEVICE_PREFIX=RSSMX100A_${RSSMX100A_INSTANCE}_PV_DEVICE_PREFIX
export RSSMX100A_CURRENT_DEVICE_IP=RSSMX100A_${RSSMX100A_INSTANCE}_DEVICE_IP
# Only works with bash
export EPICS_PV_AREA_PREFIX=${!RSSMX100A_CURRENT_PV_AREA_PREFIX}
export EPICS_PV_DEVICE_PREFIX=${!RSSMX100A_CURRENT_PV_DEVICE_PREFIX}
export EPICS_DEVICE_IP=${!RSSMX100A_CURRENT_DEVICE_IP}

# Create volume for autosave and ignore errors
/usr/bin/docker create \
    -v /opt/epics/startup/ioc/rssmx100a-epics-ioc/iocBoot/iocrssmx100a/autosave \
    --name rssmx100a-epics-ioc-${RSSMX100A_INSTANCE}-volume \
    lnlsdig/rssmx100a-epics-ioc:${IMAGE_VERSION} \
    2>/dev/null || true

# Remove a possible old and stopped container with
# the same name
/usr/bin/docker rm \
    rssmx100a-epics-ioc-${RSSMX100A_INSTANCE} || true

/usr/bin/docker run \
    --net host \
    -t \
    --rm \
    --volumes-from rssmx100a-epics-ioc-${RSSMX100A_INSTANCE}-volume \
    --name rssmx100a-epics-ioc-${RSSMX100A_INSTANCE} \
    lnlsdig/rssmx100a-epics-ioc:${IMAGE_VERSION} \
    -i "${EPICS_DEVICE_IP}" \
    -P "${EPICS_PV_AREA_PREFIX}" \
    -R "${EPICS_PV_DEVICE_PREFIX}" \
