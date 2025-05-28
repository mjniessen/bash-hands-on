#!/bin/bash

# Konfiguration
OLLAMA_URL="http://localhost:11434/api/generate"
MODEL="gemma3:latest"
PROMPT="$1"

if [ -z "$PROMPT" ]; then
  echo "Benutzung: $0 \"Dein Prompt hier\""
  exit 1
fi

# API-Streaming-Request
curl -s -N -X POST "$OLLAMA_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "prompt": "'"$PROMPT"'",
    "stream": true
  }' | while IFS= read -r line; do
  # Jede Zeile parsen und den "response"-Teil ausgeben
  echo "$line" | jq -r '.response // empty' | tr -d '\n'
done

# Sauber abschließen
echo ""
