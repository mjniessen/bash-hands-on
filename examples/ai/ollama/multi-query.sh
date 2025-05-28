#!/usr/bin/env bash
QUERY=${1}
RUNS=${2-3}

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

MODEL=($(ollama list | awk 'NR > 1 { print $1 }' | fzf))
VERSION=$(ollama --version)

fancy_info "Ollama ${VERSION##* }"
fancy_headline "$MODEL"

for ((i = 1; i <= RUNS; i++)); do
  # TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  CHAT_LOG=$(mktemp "/tmp/chatlog-XXXXXXXXX")

  fancy_run "#$i"

  # echo "$model:"
  # echo "$QUERY" >"$CHAT_LOG"
  # echo "" >>"$CHAT_LOG"

  TIMESTART=$(date +%s)
  ollama run "$MODEL" "$QUERY" | tee -a "$CHAT_LOG"
  TIMESTOP=$(date +%s)
  TIME=$((TIMESTOP - TIMESTART))
  WORDS=$(wc -w "$CHAT_LOG")
  fancy_info "${WORDS%% *} words in ${TIME}s"
  rm "$CHAT_LOG"
done
