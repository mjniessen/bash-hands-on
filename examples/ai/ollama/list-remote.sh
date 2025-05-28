#!/bin/bash

set -e

# === Konfiguration ===
OLLAMA_URL="https://ollama.com/library"
TMPFILE=$(mktemp)

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/ollama_model_list.tsv"

# Stelle sicher, dass Cache-Ordner existiert
mkdir -p "$CACHE_DIR"

trap "rm -f $TMPFILE" EXIT

# Farben definieren
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
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

# === Funktionsdefinitionen ===

check_dependencies() {
  for cmd in curl grep sed fzf ollama; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Fehlende Abhängigkeit: $cmd"
      exit 1
    fi
  done
}

get_local_models() {
  ollama list | awk 'NR>1 {print $1}'
}

fetch_base_models() {
  curl -s "$OLLAMA_URL" | grep -oP '(?<=href="/library/)[^"]+' | sort -u
}

scrape_model_info() {
  local model="$1"
  local page url desc size variants

  url="$OLLAMA_URL/$model"
  page=$(curl -s "$url")

  # Beschreibung
  desc=$(echo "$page" | perl -0777 -ne 'print $1 if /<span id="summary-content">(.*?)<\/span>/s' | sed 's/<[^>]*>//g' | tr -s '[:space:]' ' ' | sed 's/^ *//;s/ *$//')
  # desc=$(echo "$page" | grep -oP '(?<=<p>).*?(?=</p>)' | sed 's/<[^>]*>//g' | head -n 1)

  # Varianten
  variants=$(echo "$page" | grep -oP "$model(:[a-zA-Z0-9_\-]+)?" | sort -u)

  for variant in $variants; do

    url="$OLLAMA_URL/$variant"
    page=$(curl -s "${url}")

    line=$(echo "$page" | grep -oP '(?<=<p>).*?(?=</p>)' | sed 's/<[^>]*>//g' | head -n 1)
    size="${line##* }"
    hash="${line%% *}"

    [[ ! "$variant" == *:* ]] && variant="${variant}:latest"
    if ! grep -qw "$variant" <<<"$local_models"; then
      echo "$variant|$model [${hash}]|$desc|$size" >>"$TMPFILE"
    fi
  done
}

build_model_list() {
  # Wenn Cache existiert und jünger als (24h : 1440) 1 Woche : 10080 → wiederverwenden
  if [[ -f "$CACHE_FILE" && $(find "$CACHE_FILE" -mmin -10080) ]]; then
    cp "$CACHE_FILE" "$TMPFILE"
    return
  fi

  # Cache aktualisieren bzw. initial aufbauen
  {
    rm "$TMPFILE"
    for model in $base_models; do
      scrape_model_info "$model"
    done
  } &

  # Zeige den Spinner solange das Update läuft
  spinner $!

  # Cache aktualisieren
  cat "$TMPFILE" | sort -u >"$CACHE_FILE"
  cp "$CACHE_FILE" "$TMPFILE"
}

fzf_select_models() {
  cut -d "|" -f1 "$TMPFILE" | fzf -e --multi \
    --prompt="Model: " \
    --preview="awk -F'|' -v model={} '\$1 == model { print \"model: \" \$1 \"\nbasis: \" \$2 \"\nsize: \" \$4 \"\n\n\" \$3 }' \"$TMPFILE\"" \
    --preview-window=wrap
}

install_selected_models() {
  while read -r model; do
    echo "Installiere $model ..."
    ollama pull "$model"
  done <<<"$1"

}

# === Hauptablauf ===

check_dependencies

local_models=$(get_local_models)
base_models=$(fetch_base_models)

build_model_list

if [[ ! -s "$TMPFILE" ]]; then
  echo "Alle Modelle sind bereits installiert oder keine gefunden."
  exit 0
fi

selected=$(fzf_select_models)

if [[ -z "$selected" ]]; then
  echo "Keine Modelle ausgewählt."
  exit 0
fi

install_selected_models "$selected"
