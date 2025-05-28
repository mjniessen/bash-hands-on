#!/bin/bash

# Farben und Styles
BOLD="\033[1m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
RESET="\033[0m"
HEADER1="\033[95m"              # Magenta
HEADER2="\033[94m"              # Blau
HEADER3="\033[96m"              # Cyan
LIST_COLOR="\033[92m"           # Grün
CODE_COLOR="\033[93m"           # Gelb
LINK_COLOR="\033[36m"           # Hellblau
QUOTE_COLOR="\033[90m"          # Hellgrau
TABLE_HEADER="\033[97m\033[44m" # Weiß auf Blau
TABLE_CELL="\033[37m"           # Grau

in_code_block=false
in_table=false

wrap_width=80 # Maximalbreite für Umbrüche im Code-Block

wrap_text() {
  local text="$1"
  echo "$text" | fold -s -w $wrap_width
}

while IFS= read -r line; do
  # Code-Block Start/Ende
  if [[ "$line" =~ ^\`\`\` ]]; then
    if $in_code_block; then
      in_code_block=false
    else
      in_code_block=true
    fi
    continue
  fi

  if $in_code_block; then
    wrapped_code=$(wrap_text "$line")
    echo -e "${CODE_COLOR}${wrapped_code}${RESET}"
    continue
  fi

  # Tabellenzeilen erkennen
  if [[ "$line" =~ ^\|.*\|$ ]]; then
    in_table=true
    # Spalten aufteilen
    IFS='|' read -ra columns <<<"$line"
    output=""
    for col in "${columns[@]}"; do
      col=$(echo "$col" | xargs) # Whitespace entfernen
      if [[ "$col" =~ ^-+$ ]]; then
        continue # Tabellen-Trennlinie ignorieren
      fi
      if [[ "${columns[0]}" =~ ^-+$ ]]; then
        output+="$(printf "%-20s" "${TABLE_HEADER}${col}${RESET}")"
      else
        output+="$(printf "%-20s" "${TABLE_CELL}${col}${RESET}")"
      fi
    done
    echo -e "$output"
    continue
  else
    in_table=false
  fi

  # Blockzitate
  if [[ "$line" =~ ^\>\ (.*) ]]; then
    echo -e "${QUOTE_COLOR}  > ${BASH_REMATCH[1]}${RESET}"
    continue
  fi

  # Überschriften
  if [[ "$line" =~ ^###\ (.*) ]]; then
    echo -e "${HEADER3}${BOLD}${BASH_REMATCH[1]}${RESET}"
    continue
  elif [[ "$line" =~ ^##\ (.*) ]]; then
    echo -e "${HEADER2}${BOLD}${BASH_REMATCH[1]}${RESET}"
    continue
  elif [[ "$line" =~ ^#\ (.*) ]]; then
    echo -e "${HEADER1}${BOLD}${BASH_REMATCH[1]}${RESET}"
    continue
  fi

  # Listenpunkte
  if [[ "$line" =~ ^[\*\-]\ (.*) ]]; then
    echo -e "${LIST_COLOR}• ${BASH_REMATCH[1]}${RESET}"
    continue
  fi

  # Inline-Code (`code`)
  line=$(echo "$line" | sed -E "s/\`([^\`]+)\`/${CODE_COLOR}\1${RESET}/g")

  # Fett und kursiv zusammen (***text***)
  line=$(echo "$line" | sed -E "s/\*\*\*([^\*]+)\*\*\*/${BOLD}${ITALIC}\1${RESET}/g")

  # Fett (**text**)
  line=$(echo "$line" | sed -E "s/\*\*([^\*]+)\*\*/${BOLD}\1${RESET}/g")

  # Kursiv (_text_)
  line=$(echo "$line" | sed -E "s/_([^_]+)_/${ITALIC}\1${RESET}/g")

  # Unterstrichen (__text__)
  line=$(echo "$line" | sed -E "s/__([^_]+)__/${UNDERLINE}\1${RESET}/g")

  # Links [Text](URL) → nur Text einfärben
  line=$(echo "$line" | sed -E "s/\[([^\]]+)\]\([^)]+\)/${LINK_COLOR}\1${RESET}/g")

  echo -e "$line"
done
