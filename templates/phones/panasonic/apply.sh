#!/bin/bash

TEMPLITE=$(dirname $0)/template.tpl
DST_PATH=${1}
DST_FILE="${T_MAC,,}.cfg"

envsubst < ${TEMPLITE} > ${DST_PATH}/${DST_FILE}
