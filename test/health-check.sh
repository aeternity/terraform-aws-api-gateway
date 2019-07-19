#!/bin/bash

set -Eeuo pipefail

API_ADDR=$(~/bin/terraform output -json |jq -r '."api_gate_fqdn"."value"')

# Basic health check endpoint
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/healthz

# HTTP -> HTTPS redirect
curl -sSf -L -o /dev/null --retry 10 --retry-connrefused http://${API_ADDR}/v2/status

# External API
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/v2/status

# Internal API (dry-run)
EXT_STATUS=$(curl -sS -o /dev/null --retry 10 --retry-connrefused \
    -X POST -H 'Content-type: application/json' -d '{}' \
    -w "%{http_code}" \
    https://${API_ADDR}/v2/debug/transactions/dry-run)
[ $EXT_STATUS -eq 400 ]

# State Channels WebSocket API
WS_STATUS=$(curl -sS -o /dev/null --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/channel)
[ $WS_STATUS -eq 426 ]
