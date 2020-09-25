#!/bin/bash
#
source "$(dirname ${0})/common.sh"

#%
#% OpenShift Build Helper
#%
#%   This command starts a new build for the provided build config
#%
#%   Targets builds incl.: 'api', 'app-base' and 'app'
#%   Job Name: Job identifier (i.e. 'pr-5' OR 'master' or 'dev') -- defaults to 'dev'
#%
#% Usage:
#%
#%    ${THIS_FILE} [BUILD_NAME] [-apply]
#%
#% Examples:
#%
#%   Provide a target build. Defaults to a dry-run.
#%    ${THIS_FILE} api
#%
#%   Apply when satisfied.
#%    ${THIS_FILE} api -apply
#%
#%   Set variables to non-defaults at runtime.  E.g.:
#%    VERBOSE=true OC_JOB_NAME=master ${THIS_FILE} <...>
#%
#%

# Receive parameters
#
OC_JOB_NAME=${OC_JOB_NAME:-dev}
SHORTNAME=${1:-}

# E.g. <buildname>-master
#
BUILD_NAME="${SHORTNAME}"

# Cancel non complete builds and start a new build (apply or don't run)
#
OC_CANCEL_BUILD="oc -n ${PROJ_TOOLS} cancel-build bc/${BUILD_NAME}"
OC_START_BUILD="oc -n ${PROJ_TOOLS} start-build ${BUILD_NAME} --wait --follow"

# Execute commands
#
if [ "${APPLY}" ]; then
  eval "${OC_CANCEL_BUILD}"
  eval "${OC_START_BUILD}"
  # Get the most recent build version
  BUILD_LAST=$(oc -n ${PROJ_TOOLS} get bc/${BUILD_NAME} -o 'jsonpath={.status.lastVersion}')
  # Command to get the build result
  BUILD_RESULT=$(oc -n ${PROJ_TOOLS} get build/${BUILD_NAME}-${BUILD_LAST} -o 'jsonpath={.status.phase}')
  
  while [ "${BUILD_RESULT}" != "Complete" ]; do
    sleep 1
  done
fi

# Provide oc command instruction
#
display_helper "${OC_CANCEL_BUILD}" "${OC_START_BUILD}"
