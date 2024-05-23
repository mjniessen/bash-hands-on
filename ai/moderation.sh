#!/usr/bin/env bash

INPUT="$1"
[[ -z "$INPUT" ]] && exit 1

OPENAI_API_KEY=$(pass API-Keys/openai.com 2>/dev/null)
[[ -z "$OPENAI_API_KEY" ]] && exit 1

API_URL="https://api.openai.com/v1/moderations"

# Create a JSON payload with the message formatted in simple JSON
JSON_PAYLOAD=$(
  cat <<EOF
  {
    "input": "$INPUT"
  }
EOF
)

response=$(
  curl -s "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "${JSON_PAYLOAD}"
)

flagged=$(echo "$response" | jq -r '.results[].flagged')
[[ "$flagged" != "true" ]] && exit 0

categories=$(echo "$response" | jq -r '.results[].categories')

while IFS=':' read -ra arr; do
  ((${#arr[*]} < 2)) && continue
  category="${arr[0]// /}"
  boolean="${arr[1]// /}"
  if [[ "${boolean:0:4}" == 'true' ]]; then
    echo -ne "[${category:1:-1}] "
  fi
done <<<"$categories"

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
