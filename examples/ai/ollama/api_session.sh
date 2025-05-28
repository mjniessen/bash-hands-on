#!/bin/bash

MODEL="llama3.2:latest"
SESSION_ID="chat-session-003"
CONTEXT_FILE="context_$SESSION_ID.json"
SYSTEM_PROMPT="Du bist ein hilfreicher Assistent. Antworte präzise, kurz und sachlich."

TMP_FILE=$(mktemp /tmp/ollama-XXXXXXX)

# Farben definieren
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Braille Symbole für Spinner
spinner_chars=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

# Spinner-Funktion
spinner() {
  local pid=$1
  local delay=0.1
  local i=0
  local spin_color=$CYAN

  tput civis # Cursor verstecken
  while kill -0 "$pid" 2>/dev/null; do
    printf "${spin_color}%s${NC} " "${spinner_chars[i]}"
    i=$(((i + 1) % ${#spinner_chars[@]}))
    sleep "$delay"
    printf "\r" # Zurück zum Zeilenanfang
  done
  tput cnorm # Cursor wieder anzeigen
}

# Prompt aus allen übergebenen Parametern zusammenfügen
prompt="$*"
[[ -z "$prompt" ]] && echo "Fehler: Bitte Eingabe als Argument übergeben." && exit 1

# Kontextdatei initialisieren, falls sie nicht existiert
if [ ! -f "$CONTEXT_FILE" ]; then
  echo "[{\"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\"}]" >"$CONTEXT_FILE"
fi

# Bestehenden Kontext laden und neue User-Eingabe anhängen
messages=$(cat "$CONTEXT_FILE" | jq --arg prompt "$prompt" '. + [{"role": "user", "content": $prompt}]')

# Anfrage an Ollama API im Hintergrund
{
  response=$(curl -s http://localhost:11434/api/chat \
    -H "Content-Type: application/json" \
    -d '{
    "model": "'"$MODEL"'",
    "messages": '"$messages"',
    "stream": false,
    "session": "'"$SESSION_ID"'"
  }' | jq -r '.message.content')
  echo "$response" >"$TMP_FILE"
} &

# Zeige den Spinner solange die Anfrage läuft
spinner $!
response=$(cat "$TMP_FILE")

# Ausgabe der Antwort
echo -e "$response\n"

# Antwort in den Kontext übernehmen und speichern
updated_messages=$(echo "$messages" | jq --arg response "$response" '. + [{"role": "assistant", "content": $response}]')
echo "$updated_messages" >"$CONTEXT_FILE"
