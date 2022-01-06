#!/bin/sh
set -exu

DOCKER_REGISTRY=dockerregistry.lnls-sirius.com.br
DOCKER_USER_GROUP=gas
DOCKER_IMAGE_PREFIX=${DOCKER_REGISTRY}/${DOCKER_USER_GROUP}

AUTHOR="Claudio F. Carneiro <claudiofcarneiro@hotmail.com>"
BRANCH=$(git branch --no-color --show-current)
BUILD_DATE=$(date -I)
BUILD_DATE_RFC339=$(date --rfc-3339=seconds)
COMMIT=$(git rev-parse --short HEAD)
DATE=$(date -I)
DEPARTMENT=GAS
REPOSITORY=$(git remote show origin |grep Fetch|awk '{ print $3 }')

cat << EOF > .env
AUTHOR=${AUTHOR}
BRANCH=${BRANCH}
BUILD_DATE=${BUILD_DATE}
BUILD_DATE_RFC339=${BUILD_DATE_RFC339}
COMMIT_HASH=${COMMIT}
DATE=${DATE}
DEPARTMENT=${DEPARTMENT}
REPOSITORY=${REPOSITORY}

IOC_COMMIT=9411f52
IOC_GROUP=lnls-sirius
IOC_REPO=rssmx100a-epics-ioc
EOF
