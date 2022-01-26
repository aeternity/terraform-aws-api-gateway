#!/bin/bash

set -Eeuo pipefail

API_ADDR=$(terraform output -json |jq -r '."api_gate_fqdn"."value"')
echo "Checking" $API_ADDR
# Basic health check endpoint
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/healthz
echo "Checking HTTP -> HTTPS redirect"
# HTTP -> HTTPS redirect
curl -sSf -L -o /dev/null --retry 10 --retry-connrefused http://${API_ADDR}/v2/status
echo "Checking External API"
# External API
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/v2/status
echo "Checking Middleware API"
# Middleware API
curl -sSf --retry 10 --retry-connrefused https://${API_ADDR}/middleware/status
curl -sSf --retry 10 --retry-connrefused https://${API_ADDR}/mdw/status

echo "Checking Internal API (dry-run)"
# Internal API (dry-run)
EXT_STATUS=$(curl -sS --retry 10 --retry-connrefused \
    -X POST -H 'Content-type: application/json' -d '{"txs": []}' \
    -w "%{http_code}" \
    https://${API_ADDR}/v2/debug/transactions/dry-run)
[ $EXT_STATUS -eq 200 ]
echo "Checking State Channes WebScoket API"
# State Channels WebSocket API
WS_STATUS=$(curl -sS --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/channel?role=initiator)
[ $WS_STATUS -eq 426 ]
echo "Checking Middleware WebSocket API"
# Middleware WebSocket API
WS_STATUS=$(curl -sS -I --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/mdw/websocket)
[ $WS_STATUS -eq 426 ]
