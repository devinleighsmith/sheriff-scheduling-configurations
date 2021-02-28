_includeFile=$(type -p overrides.inc)
# Import ocFunctions.inc for getSecret
_ocFunctions=$(type -p ocFunctions.inc)
if [ ! -z ${_includeFile} ]; then
  . ${_ocFunctions}
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
  # Generate a random encryption key
  printStatusMsg "Creating a set of random keys ..."
  writeParameter "DATA_PROTECTION_ENCRYPTION_KEY" $(generateKey 32 | fold -w 32 | head -n 1) "false"

  # Get Location Services settings
  readParameter "LOCATION_SERVICES_CLIENT_URL - Please provide the endpoint (URL) for the Location Services API." LOCATION_SERVICES_CLIENT_URL "" "false"
  parseHostnameParameter "LOCATION_SERVICES_CLIENT_URL" "LOCATION_SERVICES_CLIENT_HOST"
  readParameter "LOCATION_SERVICES_CLIENT_USERNAME - Please provide the username to use with the Location Services API." LOCATION_SERVICES_CLIENT_USERNAME "" "false"
  readParameter "LOCATION_SERVICES_CLIENT_PASSWORD - Please provide the password to use with the Location Services API." LOCATION_SERVICES_CLIENT_PASSWORD "" "false"

  # Get KeyCloak settings
  readParameter "KEYCLOAK_AUTHORITY - Please provide the endpoint (URL) for the OIDC relaying party." KEYCLOAK_AUTHORITY "" "false"
  parseHostnameParameter "KEYCLOAK_AUTHORITY" "OIDC_RP_HOST"
  readParameter "KEYCLOAK_SECRET - Please provide the API secret toi use with the OIDC relaying party." KEYCLOAK_SECRET "" "false"
  readParameter "SITEMINDER_LOGOUT_URL - Please provide the SiteMinder Logout URL." SITEMINDER_LOGOUT_URL "" "false"

  # Get the email settings
  readParameter "EMAIL_SERVICE_URL - Please provide the url for the CHES email api.  The default is a blank string." EMAIL_SERVICE_URL "" "false"
  parseHostnameParameter "EMAIL_SERVICE_URL" "EMAIL_SERVICE_HOST"
  readParameter "EMAIL_SERVICE_AUTH_URL - Please provide the url for the CHES authentication endpoint.  The default is a blank string." EMAIL_SERVICE_AUTH_URL "" "false"
  parseHostnameParameter "EMAIL_SERVICE_AUTH_URL" "EMAIL_SERVICE_AUTH_HOST"
  readParameter "EMAIL_SERVICE_CLIENT_ID - Please provide the service client id for sending access request emails.  The default is a blank string." EMAIL_SERVICE_CLIENT_ID "" "false"
  readParameter "EMAIL_SERVICE_CLIENT_SECRET - Please provide the service client secret to use with above id.  The default is a blank string." EMAIL_SERVICE_CLIENT_SECRET "" "false"
  readParameter "SENDER_EMAIL - Please provide the email address used for sending access request emails.  The default is a blank string." SENDER_EMAIL "" "false"
  readParameter "SENDER_NAME - Please provide the name to use with the above email address.  The default is a blank string." SENDER_NAME "" "false"
  readParameter "REQUEST_ACCESS_EMAIL - Please provide the email address used for receiving access request emails.  The default is a blank string." REQUEST_ACCESS_EMAIL "" "false"
else
  printStatusMsg "Update operation detected ...\nSkipping the generation of keys ...\n"
  writeParameter "DATA_PROTECTION_ENCRYPTION_KEY" "generation_skipped" "false"

  printStatusMsg "Update operation detected ...\nSkipping the prompts for LOCATION_SERVICES_CLIENT_URL, LOCATION_SERVICES_CLIENT_USERNAME, LOCATION_SERVICES_CLIENT_PASSWORD, KEYCLOAK_AUTHORITY, KEYCLOAK_SECRET, SITEMINDER_LOGOUT_URL, EMAIL_SERVICE_URL, EMAIL_SERVICE_AUTH_URL, EMAIL_SERVICE_CLIENT_ID, EMAIL_SERVICE_CLIENT_SECRET, SENDER_EMAIL, SENDER_NAME, and REQUEST_ACCESS_EMAIL ...\n"
  writeParameter "LOCATION_SERVICES_CLIENT_URL" "prompt_skipped" "false"
  writeParameter "LOCATION_SERVICES_CLIENT_USERNAME" "prompt_skipped" "false"
  writeParameter "LOCATION_SERVICES_CLIENT_PASSWORD" "prompt_skipped" "false"

  writeParameter "KEYCLOAK_AUTHORITY" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_SECRET" "prompt_skipped" "false"
  writeParameter "SITEMINDER_LOGOUT_URL" "prompt_skipped" "false"

  writeParameter "EMAIL_SERVICE_URL" "prompt_skipped" "false"
  writeParameter "EMAIL_SERVICE_AUTH_URL" "prompt_skipped" "false"
  writeParameter "EMAIL_SERVICE_CLIENT_ID" "prompt_skipped" "false"
  writeParameter "EMAIL_SERVICE_CLIENT_SECRET" "prompt_skipped" "false"
  writeParameter "SENDER_EMAIL" "prompt_skipped" "false"
  writeParameter "SENDER_NAME" "prompt_skipped" "false"
  writeParameter "REQUEST_ACCESS_EMAIL" "prompt_skipped" "false"

  # Get OIDC_RP_HOST from secret
  printStatusMsg "Getting OIDC_RP_HOST for the ExternalNetwork definition from secret ...\n"
  writeParameter "OIDC_RP_HOST" $(getSecret "${NAME}" "oidc-rp-host") "false"

  # Get LOCATION_SERVICES_CLIENT_HOST from secret
  printStatusMsg "Getting LOCATION_SERVICES_CLIENT_HOST for the ExternalNetwork definition from secret ...\n"
  writeParameter "LOCATION_SERVICES_CLIENT_HOST" $(getSecret "${NAME}" "location-services-client-host") "false"

  # Get EMAIL_SERVICE_HOST from secret
  printStatusMsg "Getting EMAIL_SERVICE_HOST for the ExternalNetwork definition from secret ...\n"
  writeParameter "EMAIL_SERVICE_HOST" $(getSecret "${NAME}" "email-service-host") "false"

  # Get EMAIL_SERVICE_AUTH_HOST from secret
  printStatusMsg "Getting EMAIL_SERVICE_AUTH_HOST for the ExternalNetwork definition from secret ...\n"
  writeParameter "EMAIL_SERVICE_AUTH_HOST" $(getSecret "${NAME}" "email-service-auth-host") "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}