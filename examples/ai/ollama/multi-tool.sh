#!/bin/bash

PROMPT="${1-What is 48 * 7 + 6 ?}"

MODEL="llama3.2:latest"
SESSION_ID="chat-session-$(date -u +%s)"
CONTEXT_FILE=$(mktemp "/tmp/ollama-XXXXXXXX")
TMP_FILE=$(mktemp "/tmp/ollama-XXXXXXXX")
DEBUG=false

SYSTEM_PROMPT="You can use tools and you should. Use CALL:calculator(...) to use bc as needed.\
  Use CALL:date() to get actual date as needed.\
  Use CALL:time() to get local time as needed.\
  Use CALL:utc() to get utc timestamp as needed.\
  Use CALL:weekday() to get actual day of week as needed.\
  Use CALL:location() to get actual geolocation as needed.\
  Use CALL:file_lookup(...) to get content of a local file as needed.\
  Results will be shown within user prompts. Provide a correct, but very short answers as soon as possible. Summarize given answers."
TEMPERATURE=0.2

# Farben definieren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Nerd Font Symbole für Spinner
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

# optionale Ausgabe von Debug Informationen
debug_info() {
  if $DEBUG; then
    echo -e "${YELLOW}${1}${NC}"
  fi
}

# System Prompt in den Kontext setzen
echo "[{\"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\"}]" >"$CONTEXT_FILE"

while true; do

  # Prompt dem Kontext hinzufügen
  messages=$(jq --arg prompt "$PROMPT" '. + [{"role": "user", "content": $prompt}]' <"${CONTEXT_FILE}")

  debug_info "[Sending to Model]: $PROMPT"
  debug_info "$SESSION_ID"
  debug_info "$messages"

  # Anfrage an Ollama API im Hintergrund
  {
    response=$(curl -s http://localhost:11434/api/chat \
      -H "Content-Type: application/json" \
      -d '{
      "model": "'"$MODEL"'",
      "messages": '"$messages"',
      "stream": false,
      "temperature": '"$TEMPERATURE"',
      "session": "'"$SESSION_ID"'"
    }' | jq -r '.message.content')
    echo "$response" >"$TMP_FILE"
  } &

  # Zeige den Spinner solange die Anfrage läuft
  spinner $!
  RESPONSE=$(cat "$TMP_FILE")

  debug_info "$RESPONSE"

  # Tool dispatch
  if [[ "$RESPONSE" =~ CALL:calculator\((.*)\) ]]; then
    EXPRESSION="${BASH_REMATCH[1]}"
    RESULT=$(echo "$EXPRESSION" | bc -l)
    debug_info "-- tool: calculator => Expression: $EXPRESSION => Result: $RESULT"
    PROMPT="Result from calculator: $RESULT"

  elif [[ "$RESPONSE" =~ CALL:bc\((.*)\) ]]; then
    EXPRESSION="${BASH_REMATCH[1]}"
    RESULT=$(echo "$EXPRESSION" | bc -l)
    debug_info "-- tool: bc => Expression: $EXPRESSION => Result: $RESULT"
    PROMPT="Result from bc: $RESULT"

  elif [[ "$RESPONSE" =~ CALL:date(.*) ]]; then
    RESULT=$(date +'%F %R UTC%:::z')
    debug_info "-- tool: date => Result: $RESULT"
    PROMPT="$PROMPT Today is $RESULT."

  elif [[ "$RESPONSE" =~ CALL:time(.*) ]]; then
    RESULT=$(date +'%R UTC%:::z')
    debug_info "-- tool: time => Result: $RESULT"
    PROMPT="$PROMPT Local time is $RESULT."

  elif [[ "$RESPONSE" =~ CALL:utc(.*) ]]; then
    RESULT=$(date -u)
    debug_info "-- tool: time => Result: $RESULT"
    PROMPT="$PROMPT It is $RESULT."

  elif [[ "$RESPONSE" =~ CALL:location(.*) ]]; then
    RESULT="Bergisch Gladbach, NRW, Germany"
    debug_info "-- tool: location => Result: $RESULT"
    PROMPT="$PROMPT Location is $RESULT."

  elif [[ "$RESPONSE" =~ CALL:weekday(.*) ]]; then
    RESULT=$(date +'%A')
    debug_info "\033[1;35m[Tool: Date]\033[0m Result: $RESULT"
    PROMPT="$PROMPT Weekday is $RESULT."

  elif [[ "$RESPONSE" =~ CALL:web_search\(\"([^\"]*)\"\) ]]; then
    QUERY="${BASH_REMATCH[1]}"
    RESULT="Simulated web search result for '$QUERY'"
    debug_info "\033[1;35m[Tool: Web Search]\033[0m Query: $QUERY => Result: $RESULT"
    PROMPT="Result: $RESULT"

  elif [[ "$RESPONSE" =~ CALL:file_lookup\((.*)\) ]]; then
    FILE="${BASH_REMATCH[1]}"
    if [[ -f "$FILE" ]]; then
      RESULT=$(head -c 500 "$FILE")
    else
      RESULT="Error: File '$FILE' not found."
    fi
    debug_info "\033[1;35m[Tool: File Lookup]\033[0m File: $FILE => Result: $RESULT"
    PROMPT="Result: $RESULT"

  else
    echo "$RESPONSE"
    break
  fi
done
