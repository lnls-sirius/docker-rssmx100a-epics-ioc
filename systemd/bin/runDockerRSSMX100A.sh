#!/usr/bin/env bash

set -u

if [ -z "$RSSMX100A_INSTANCE" ]; then
    echo "RSSMX100A_INSTANCE environment variable is not set." >&2
    exit 1
fi

export RSSMX100A_CURRENT_PV_AREA_PREFIX=RSSMX100A_${RSSMX100A_INSTANCE}_PV_AREA_PREFIX
export RSSMX100A_CURRENT_PV_DEVICE_PREFIX=RSSMX100A_${RSSMX100A_INSTANCE}_PV_DEVICE_PREFIX
export RSSMX100A_CURRENT_DEVICE_IP=RSSMX100A_${RSSMX100A_INSTANCE}_DEVICE_IP
export RSSMX100A_CURRENT_TELNET_PORT=RSSMX100A_${RSSMX100A_INSTANCE}_TELNET_PORT
# Only works with bash
export EPICS_PV_AREA_PREFIX=${!RSSMX100A_CURRENT_PV_AREA_PREFIX}
export EPICS_PV_DEVICE_PREFIX=${!RSSMX100A_CURRENT_PV_DEVICE_PREFIX}
export EPICS_DEVICE_IP=${!RSSMX100A_CURRENT_DEVICE_IP}
export EPICS_TELNET_PORT=${!RSSMX100A_CURRENT_TELNET_PORT}

if [ -z "${RSSMX100A_CURRENT_TELNET_PORT}" ]; then
    echo "TELNET port is not set." >&2
    exit 1
fi

RSSMX100A_TYPE=$(echo ${RSSMX100A_INSTANCE} | grep -Eo "[^0-9]+");

if [ -z "$RSSMX100A_TYPE" ]; then
    echo "Device instance is not valid. Valid device options are: SMA, and SMB." >&2
    echo "The instance format is: <device type><device index>. Example: SMA1" >&2
    exit 5
fi

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
    -t "${EPICS_TELNET_PORT}" \
    -d "${RSSMX100A_TYPE}" \
    -i "${EPICS_DEVICE_IP}" \
    -P "${EPICS_PV_AREA_PREFIX}" \
    -R "${EPICS_PV_DEVICE_PREFIX}" \
