#!/usr/bin/env bash

PROMPT="$1"
[[ -z "$PROMPT" ]] && exit 1

ARR_IMG_SIZE=('256x256' '512x512' '1024x1024' '1024x1792' '1792x1024')
if [[ " ${ARR_IMG_SIZE[*]} " == *" $2 "* ]]; then
  IMG_SIZE="$2"
else
  IMG_SIZE="1024x1024"
fi

OPENAI_API_KEY=$(pass API-Keys/openai.com 2>/dev/null)
[[ -z "$OPENAI_API_KEY" ]] && exit 1

API_URL="https://api.openai.com/v1/images/generations"
AI_MODEL="dall-e-3"

# Create a JSON payload with the message formatted in simple JSON
JSON_PAYLOAD=$(
  cat <<EOF
  {
    "model": "$AI_MODEL",
    "prompt": "$PROMPT", 
    "n": 1,
    "size": "$IMG_SIZE"
  }
EOF
)

response=$(
  curl -s "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "${JSON_PAYLOAD}"
)

revised_prompt=$(echo "$response" | jq -r '.data[].revised_prompt')
img_url=$(echo "$response" | jq -r '.data[].url')
img_file="image-$(date +'%Y%m%d%H%M%S').png"

curl -s "$img_url" --output "$img_file"
chafa --center=on "$img_file"
xclip -selection clipboard -t image/png -i "$img_file"

echo "File: $img_file"
echo "Revised prompt: \"$revised_prompt\""

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
