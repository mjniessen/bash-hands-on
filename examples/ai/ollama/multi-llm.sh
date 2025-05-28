#!/usr/bin/env bash
QUERY=${1}

function fancy_info() {
  printf '\n\e[48;2;0;200;0m\e[1m\e[38;2;0;0;0m %s \e[0m' "${1}"
  printf '\e[38;2;0;200;0m\e[1m\e[48;2;0;0;0m\e[0m\n'
}

function fancy_headline() {
  printf '\n\e[48;2;255;255;0m\e[1m\e[3m\e[38;2;0;0;0m 󰚩  %s\e[0m' "${1} "
  printf '\e[38;2;255;255;0m\e[1m\e[48;2;0;0;0m\e[0m\n\n'
}

MODELS=($(ollama list | awk 'NR > 1 { print $1 }' | fzf -m))
VERSION=$(ollama --version)

# Ersetze 'echo' mit 'fancy_info', bei installierten Nerd Fonts
echo "Ollama ${VERSION##* }"

for MODEL in "${MODELS[@]}"; do

  # Auto-Logfile
  TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  CHAT_LOG="chatlog-${MODEL}-${TIMESTAMP}.md"

  # Ersetze 'echo' mit 'fancy_headline', bei installierten Nerd Fonts
  echo "$MODEL"

  # echo "$model:"
  echo "$QUERY" >"$CHAT_LOG"
  echo "" >>"$CHAT_LOG"

  TIMESTART=$(date +%s)
  ollama run "$MODEL" "$QUERY" | tee -a "$CHAT_LOG"
  TIMESTOP=$(date +%s)
  TIME=$((TIMESTOP - TIMESTART))
  WORDS=$(wc -w "$CHAT_LOG")

  # Ersetze 'echo' mit 'fancy_info', bei installierten Nerd Fonts
  echo "${WORDS%% *} words in ${TIME}s"
done
