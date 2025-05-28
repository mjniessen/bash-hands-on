#!/usr/bin/env bash
QUERY=${1}

TEMPERATURE=(0.2 0.5 1.0 1.5)

# Konfiguration
OLLAMA_URL="http://localhost:11434/api/generate"

function fancy_info() {
  printf '\n\e[48;2;0;200;0m\e[1m\e[38;2;0;0;0m %s \e[0m' "${1}"
  printf '\e[38;2;0;200;0m\e[1m\e[48;2;0;0;0m\e[0m\n'
}

function fancy_run() {
  printf '\n\e[48;2;0;0;200m\e[1m\e[38;2;255;255;255m %s \e[0m' "${1}"
  printf '\e[38;2;0;0;200m\e[1m\e[48;2;0;0;0m\e[0m\n\n'
}

function fancy_headline() {
  printf '\n\e[48;2;255;255;0m\e[1m\e[3m\e[38;2;0;0;0m 󰚩  %s\e[0m' "${1} "
  printf '\e[38;2;255;255;0m\e[1m\e[48;2;0;0;0m\e[0m\n'
}

MODEL=$(ollama list | awk 'NR > 1 { print $1 }' | fzf)
VERSION=$(ollama --version)

fancy_info "Ollama ${VERSION##* }"
fancy_headline "$MODEL"

for ((i = 0; i < ${#TEMPERATURE[@]}; i++)); do

  fancy_run "Temperature: ${TEMPERATURE[i]}"

  # echo "$model:"
  # echo "$QUERY" >"$CHAT_LOG"
  # echo "" >>"$CHAT_LOG"

  TIMESTART=$(date +%s)

  # API-Aufruf
  curl -s -X POST "$OLLAMA_URL" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "'"$MODEL"'",
      "prompt": "'"$QUERY"'",
      "stream": false,
      "temperature": '${TEMPERATURE[i]}'
    }' | jq -r '.response'

  TIMESTOP=$(date +%s)
  TIME=$((TIMESTOP - TIMESTART))
  # WORDS=$(wc -w "$CHAT_LOG")
  # fancy_info "${WORDS%% *} words in ${TIME}s"
done
