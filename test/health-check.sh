#!/bin/bash

set -Eeuo pipefail

main_api_name=$(terraform output -json |jq -r '."main-api-name"."value"')
origin_api_name=$(terraform output -json |jq -r '."origin-api-name"."value"')

curl -s -f -S -L -o /dev/null --retry 10 --retry-connrefused http://${main_api_name}/v2/status
curl -s -f -S -o /dev/null --retry 10 --retry-connrefused http://${origin_api_name}:8080/healthz
