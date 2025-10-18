#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[fetch_access_token] %s\n' "$*" 1>&2
}

require_env() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    log "Environment variable '${var_name}' must be set before running this script."
    exit 1
  fi
}

require_env "NAMI_CLIENT_ID"
require_env "NAMI_CLIENT_SECRET"
require_env "NAMI_PLACE_ID"

fetch_value() {
  local json_key="$1"
  python3 -c '
import json
import sys

raw = sys.stdin.read()
key = sys.argv[1]

try:
    payload = json.loads(raw)
except json.JSONDecodeError as exc:
    raise SystemExit(
        f"Failed to decode JSON while looking for {key!r}: {exc}\nRaw response:\n{raw}"
    )

if key not in payload:
    raise SystemExit(f"Expected key {key!r} missing in response: {payload}")

print(payload[key])
' "$json_key"
}

log "Requesting service-level access token..."
service_response=$(
  curl -sS --fail -X POST \
    --url "https://app.nami.surf/oauth/token" \
    --header "content-type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=${NAMI_CLIENT_ID}" \
    --data-urlencode "client_secret=${NAMI_CLIENT_SECRET}" \
    --data-urlencode "grant_type=client_credentials"
) || {
  log "Failed to obtain service-level token. Verify credentials and network access."
  exit 1
}
if [[ -z "${service_response}" ]]; then
  log "Service token response was empty."
  exit 1
fi
service_token=$(printf '%s' "${service_response}" | fetch_value "access_token")

log "Requesting place-level access token..."
place_response=$(
  curl -sS --fail -X GET \
    "https://mangahume.nami.surf/commissioningv1/places/${NAMI_PLACE_ID}" \
    -H "authorization: Bearer ${service_token}" \
    -H "content-type: application/json"
) || {
  log "Failed to obtain place-level token for place '${NAMI_PLACE_ID}'."
  exit 1
}
if [[ -z "${place_response}" ]]; then
  log "Place token response was empty."
  exit 1
fi
place_token=$(printf '%s' "${place_response}" | fetch_value "access_token")

log "Returning place-level access token."
printf '%s\n' "${place_token}"
