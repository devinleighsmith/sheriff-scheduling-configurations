_includeFile=$(type -p overrides.inc)
if [ ! -z ${_includeFile} ]; then
  . ${_includeFile}
else
  _red='\033[0;31m'; _yellow='\033[1;33m'; _nc='\033[0m'; echo -e \\n"${_red}overrides.inc could not be found on the path.${_nc}\n${_yellow}Please ensure the openshift-developer-tools are installed on and registered on your path.${_nc}\n${_yellow}https://github.com/BCDevOps/openshift-developer-tools${_nc}"; exit 1;
fi

# ================================================================================================================
# Special deployment parameters needed for injecting a user supplied settings into the deployment configuration
# ----------------------------------------------------------------------------------------------------------------
# The results need to be encoded as OpenShift template parameters for use with oc process.
# ================================================================================================================

if createOperation; then
  # Prompts
  readParameter "LOCATION_SERVICES_CLIENT_URL - Please provide the endpoint (URL) for the Location Services API." LOCATION_SERVICES_CLIENT_URL "false" 
  readParameter "LOCATION_SERVICES_CLIENT_USERNAME - Please provide the username to use with the Location Services API." LOCATION_SERVICES_CLIENT_USERNAME "false" 
  readParameter "LOCATION_SERVICES_CLIENT_PASSWORD - Please provide the password to use with the Location Services API." LOCATION_SERVICES_CLIENT_PASSWORD "false" 
  readParameter "KEYCLOAK_AUTHORITY - Please provide the endpoint (URL) for the OIDC relaying party." KEYCLOAK_AUTHORITY "false" 
  readParameter "KEYCLOAK_SECRET - Please provide the API secret toi use with the OIDC relaying party." KEYCLOAK_SECRET "false" 
else
  printStatusMsg "Update operation detected ...\nSkipping the prompts for LOCATION_SERVICES_CLIENT_URL, LOCATION_SERVICES_CLIENT_USERNAME, LOCATION_SERVICES_CLIENT_PASSWORD, KEYCLOAK_AUTHORITY, and KEYCLOAK_SECRET ...\n"
  writeParameter "LOCATION_SERVICES_CLIENT_URL" "prompt_skipped" "false"
  writeParameter "LOCATION_SERVICES_CLIENT_USERNAME" "prompt_skipped" "false"
  writeParameter "LOCATION_SERVICES_CLIENT_PASSWORD" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_AUTHORITY" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_SECRET" "prompt_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}