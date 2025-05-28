#!/bin/bash

# Farben und Styles
BOLD='\\e[1m'
ITALIC='\\e[3m'
UNDERLINE='\\e[4m'
RESET='\\e[0m'
HEADER1="\033[95m"              # Magenta
HEADER2="\033[94m"              # Blau
HEADER3="\033[96m"              # Cyan
LIST_COLOR="\033[92m"           # Grün
CODE_COLOR='\\e[96m'            # Gelb
LINK_COLOR="\033[36m"           # Hellblau
QUOTE_COLOR="\033[90m"          # Hellgrau
TABLE_HEADER="\033[97m\033[44m" # Weiß auf Blau
TABLE_CELL="\033[37m"           # Grau

# Prüfen, ob eine Datei angegeben wurde
if [ $# -lt 1 ]; then
  echo "Benutzung: $0 <markdown_datei>"
  exit 1
fi

input_file="$1"

# Prüfen, ob die Datei existiert
if [ ! -f "$input_file" ]; then
  echo "Datei nicht gefunden: $input_file"
  exit 1
fi

# Temporäre Datei für extrahierten Code
tmp_code=$(mktemp)

# Extrahiere Codeblöcke aus Markdown
# Nur Zeilen zwischen ``` und ``` werden extrahiert
inside_code_block=false
language=""

while IFS= read -r line; do
  if [[ "$line" =~ ^\`\`\` ]]; then
    if $inside_code_block; then
      inside_code_block=false
      # Am Ende des Codeblocks: mit bat anzeigen
      if [ -n "$language" ]; then
        bat -p --language="$language" "$tmp_code"
      else
        bat -p "$tmp_code"
      fi
      # Leeren für nächsten Block
      echo "" >"$tmp_code"
    else
      inside_code_block=true
      # Hole Sprache, falls angegeben (z.B. ```bash)
      language=$(echo "$line" | sed -E 's/^```//')
    fi
  else
    if $inside_code_block; then
      echo "$line" >>"$tmp_code"
    else
      # Fett und kursiv zusammen (***text***)
      line=$(echo "$line" | sed -E "s/\*\*\*([^\*]+)\*\*\*/${BOLD}${ITALIC}\1${RESET}/g")

      # Fett (**text**)
      line=$(echo "$line" | sed -E "s/\*\*([^\*]+)\*\*/${BOLD}\1${RESET}/g")

      # Inline-Code (`code`)
      line=$(echo "$line" | sed -E "s/\`([^\`]+)\`/${CODE_COLOR}${ITALIC}\1${RESET}/g")

      # Kursiv (_text_)
      line=$(echo "$line" | sed -E "s/_([^_]+)_/${ITALIC}\1${RESET}/g")

      # Unterstrichen (__text__)
      line=$(echo "$line" | sed -E "s/__([^_]+)__/${UNDERLINE}\1${RESET}/g")

      echo -e "$line"
    fi
  fi
done <"$input_file"

# Aufräumen
rm -f "$tmp_code"
