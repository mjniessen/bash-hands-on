#!/bin/bash

# Konfiguration
OLLAMA_URL="http://localhost:11434/api/generate" # Ollama läuft normalerweise lokal
MODEL="gemma3:latest"                            # Name des Modells, z.B. llama3
PROMPT="$1"                                      # Prompt wird als erster Parameter übergeben

# Prüfen, ob ein Prompt angegeben wurde
if [ -z "$PROMPT" ]; then
  echo "Benutzung: $0 \"Dein Prompt hier\""
  exit 1
fi

# API-Aufruf
curl -s -X POST "$OLLAMA_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "prompt": "'"$PROMPT"'",
    "stream": false
  }' | jq -r '.response'
