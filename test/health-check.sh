#!/bin/bash

set -Eeuo pipefail

API_ADDR=$(terraform output -json |jq -r '."api_gate_fqdn"."value"')
echo "Checking" $API_ADDR
# Basic health check endpoint
echo "https://${API_ADDR}/healthz"
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/healthz
echo "http://${API_ADDR}/v2/status"
# HTTP -> HTTPS redirect
curl -sSf -L -o /dev/null --retry 10 --retry-connrefused http://${API_ADDR}/v2/status
echo "https://${API_ADDR}/v2/status"
# External API
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/v2/status
echo "https://${API_ADDR}/middleware/status"
echo "https://${API_ADDR}/mdw/status"
# Middleware API
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/middleware/status
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/mdw/status


# Internal API (dry-run)
EXT_STATUS=$(curl -sS -o /dev/null --retry 10 --retry-connrefused \
    -X POST -H 'Content-type: application/json' -d '{"txs": []}' \
    -w "%{http_code}" \
    https://${API_ADDR}/v2/debug/transactions/dry-run)
[ $EXT_STATUS -eq 200 ]

# State Channels WebSocket API
WS_STATUS=$(curl -sS -o /dev/null --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/channel?role=initiator)
[ $WS_STATUS -eq 426 ]

# Middleware WebSocket API
WS_STATUS=$(curl -sS -I -o /dev/null --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/mdw/websocket)
[ $WS_STATUS -eq 426 ]
