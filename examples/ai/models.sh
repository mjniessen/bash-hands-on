#!/usr/bin/env bash

OPENAI_API_KEY=$(pass API-Keys/openai.com 2>/dev/null)
URL="https://api.openai.com/v1/models"

response=$(curl -s -H "Authorization: Bearer ${OPENAI_API_KEY}" ${URL})
models=$(echo "${response}" | jq -r '.data[] | .id' | sort)

echo "$models"
