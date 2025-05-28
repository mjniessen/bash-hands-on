#!/bin/bash

MODEL="llama3.2:latest"
SESSION_ID="chat-session-002"
CONTEXT_FILE="context_$SESSION_ID.json"
SYSTEM_PROMPT="Du bist ein erfahrener Unix-Systemadministrator. Antworte präzise und sachlich."

# Prompt aus CLI-Parametern
prompt="$*"
[[ -z "$prompt" ]] && echo "Fehler: Bitte Eingabe als Argument übergeben." && exit 1

# Kontextdatei initialisieren, falls nicht vorhanden
if [ ! -f "$CONTEXT_FILE" ]; then
  echo "[{\"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\"}]" >"$CONTEXT_FILE"
fi

# Kontext laden und neue User-Eingabe hinzufügen
messages=$(cat "$CONTEXT_FILE" | jq --arg prompt "$prompt" '. + [{"role": "user", "content": $prompt}]')

# Anzeige: Live-Ausgabe simulieren
echo -e "Assistant: \c"

# Streaming-Request an Ollama (Zeile für Zeile lesen)
response=""
curl -s http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "messages": '"$messages"',
    "stream": true,
    "session": "'"$SESSION_ID"'"
  }' | while read -r line; do
  # Extrahiere den Content (wenn vorhanden)
  content=$(echo "$line" | jq -r '.message.content // empty')
  if [ -n "$content" ]; then
    echo -n "$content"
    response+="$content"
  fi
done

echo -e "\n"

# Kontext aktualisieren und speichern
updated_messages=$(echo "$messages" | jq --arg response "$response" '. + [{"role": "assistant", "content": $response}]')
echo "$updated_messages" >"$CONTEXT_FILE"
