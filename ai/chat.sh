#!/usr/bin/env bash

PROMPT="$1"
[[ -z "$PROMPT" ]] && exit 1

OPENAI_API_KEY=$(pass API-Keys/openai.com 2>/dev/null)
[[ -z "$OPENAI_API_KEY" ]] && exit 1

API_URL="https://api.openai.com/v1/chat/completions"
AI_MODEL="gpt-3.5-turbo"

# Create a JSON payload with the message formatted in simple JSON
JSON_PAYLOAD=$(
  cat <<EOF
  {
    "model": "$AI_MODEL",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "$PROMPT"
      }
    ]
  }
EOF
)

response=$(
  curl -s "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "${JSON_PAYLOAD}"
)

echo "$response" | jq -r '.choices[].message.content'

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
