#!/usr/bin/env bash

PROMPT="$*"
[[ -z "$PROMPT" ]] && exit 1

OPENAI_API_KEY=$(pass API-Keys/openai.com 2>/dev/null)
[[ -z "$OPENAI_API_KEY" ]] && exit 1

API_URL="https://api.openai.com/v1/chat/completions"
AI_MODEL="gpt-4o"

OS_SYSTEM=$(lsb_release -d | grep Description | sed 's/.*:.[ ]+//')

# Create a JSON payload with the message formatted in simple JSON
JSON_PAYLOAD=$(
  cat <<EOF
  {
    "model": "$AI_MODEL",
    "messages": [
      {
        "role": "system",
        "content": "Return the bash command to be executed in a linux environment directly. \
          No markdown. Just the command."
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

bash_command=$(echo "$response" | jq -r '.choices[].message.content')

echo "$bash_command" | bat -pp -lbash
echo "$bash_command" | xclip -r -sel clip

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
