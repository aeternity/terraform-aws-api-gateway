#!/bin/bash

set -Euo pipefail

# API_ADDR=$(terraform output -json |jq -r '."api_gate_fqdn"."value"')
API_ADDR=testnet.aeternity.io

FAILED=false
check_status () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "FAILED"
        FAILED=true
    fi    
}

echo -n "Checking $API_ADDR ... "
# Basic health check endpoint
curl -sSf -o /dev/null --retry 8 --retry-connrefused --retry-max-time 360 https://${API_ADDR}/healthz
check_status

echo -n "Checking External API ... "
# External API
curl -sSf -o /dev/null --retry 5 --retry-connrefused --retry-max-time 60 https://${API_ADDR}/v3/status
check_status

echo -n "Checking HTTP -> HTTPS redirect ... "
# HTTP -> HTTPS redirect
curl -sSf -L -o /dev/null --retry 10 --retry-connrefused http://${API_ADDR}/v3/status
check_status

echo -n "Checking Middleware API ... "
# Middleware API
curl -sSf -o /dev/null --retry 10 --retry-connrefused https://${API_ADDR}/mdw/status
check_status

echo -n "Checking Internal API (dry-run) ... "
# Internal API (dry-run)
EXT_STATUS=$(curl -sSf -o /dev/null --retry 10 --retry-connrefused \
    -X POST -H 'Content-type: application/json' -d '{"txs": []}' \
    -w "%{http_code}" \
    https://${API_ADDR}/v3/debug/transactions/dry-run)
[ $EXT_STATUS -eq 200 ]
check_status

echo -n "Checking State Channes WebScoket API ... "
# State Channels WebSocket API
WS_STATUS=$(curl -sS -o /dev/null --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/channel?role=initiator)
[ $WS_STATUS -eq 426 ]
check_status
if [ $WS_STATUS -ne 426 ]; then
    echo "  (HTTP status code: $WS_STATUS)"
fi

echo -n "Checking Middleware WebSocket API ... "
# Middleware WebSocket API
WS_STATUS=$(curl -sS -I -o /dev/null --retry 10 --retry-connrefused \
    -w "%{http_code}" \
    https://${API_ADDR}/mdw/v2/websocket)
[ $WS_STATUS -eq 426 ]
check_status
if [ $WS_STATUS -ne 426 ]; then
    echo "  (HTTP status code: $WS_STATUS)"
fi

if [ $FAILED = true ]; then
    echo "Some checks failed."
    exit 1
else
    echo "All checks passed."
fi
