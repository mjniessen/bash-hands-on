#!/usr/bin/env bash

# The message you want to send.
MESSAGE="$*"
[[ -n $MESSAGE ]] || exit 1

# Define the webhook URL
WEBHOOK_URL=$(pass 'Webhook/Linux Training' 2>/dev/null)
[[ -n $WEBHOOK_URL ]] || exit 1

# Create a JSON payload with the message formatted in simple JSON
JSON_PAYLOAD=$(
  cat <<EOF
  {
    "text": "${MESSAGE}"
  }
EOF
)

# Use curl to send the POST request
curl -H "Content-Type: application/json" -d "${JSON_PAYLOAD}" "${WEBHOOK_URL}"

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
