#!/usr/bin/env bash

set -e

# Funktion: Tool-Check
check_tool() {
  local tool="$1"
  if ! command -v "$tool" &>/dev/null; then
    echo "❌ Benötigtes Tool '$tool' ist nicht installiert."
    MISSING_TOOLS=true
  fi
}

# Toolliste nach Dateityp
declare -A MIME_TOOL_MAP=(
  ["application/pdf"]="pdftotext"
  ["application/msword"]="pandoc"
  ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]="pandoc"
  ["application/vnd.oasis.opendocument.text"]="pandoc"
  ["application/rtf"]="unrtf"
  ["audio/mpeg"]="whisper"
  ["audio/wav"]="whisper"
)

# MIME → Sprache für Markdown
declare -A MIME_TO_LANG=(
  ["text/x-python"]="python"
  ["text/x-csrc"]="c"
  ["text/x-c++src"]="cpp"
  ["text/x-java"]="java"
  ["application/javascript"]="javascript"
  ["text/x-go"]="go"
  ["text/x-rustsrc"]="rust"
  ["text/x-php"]="php"
  ["text/x-sql"]="sql"
  ["text/x-lua"]="lua"
  ["text/x-scala"]="scala"
  ["text/x-typescript"]="typescript"
  ["text/x-markdown"]="markdown"
  ["application/x-sh"]="bash"
  ["text/x-shellscript"]="bash"
  ["text/x-makefile"]="makefile"
  ["text/x-dockerfile"]="dockerfile"
  ["text/x-config"]="ini"
  ["application/x-yaml"]="yaml"
  ["application/json"]="json"
  ["text/plain"]="text"
)

TEXT_MIME_TYPES=(
  "text/plain"
  "application/json"
  "application/xml"
  "text/html"
  "text/csv"
  "text/markdown"
  "application/x-yaml"
)

CODE_MIME_TYPES=("${!MIME_TO_LANG[@]}")

# CODE_MIME_TYPES=(
#  "text/x-python"
#  "text/x-csrc"
#  "text/x-c++src"
#  "text/x-java"
#  "application/javascript"
#  "text/x-go"
#  "text/x-rustsrc"
#  "text/x-php"
#  "text/x-sql"
#  "text/x-lua"
#  "text/x-scala"
#  "text/x-typescript"
#  "text/x-markdown"
#  "text/x-toml"
#  "text/x-makefile"
#  "text/x-dockerfile"
#  "text/x-config"
#  "text/x-shellscript"
# )

# Parameter prüfen
if [ $# -eq 0 ]; then
  echo "⚠️  Bitte gib den Pfad zu einer Datei an."
  exit 1
fi

FILE="$1"
if [ ! -f "$FILE" ]; then
  echo "❌ Datei nicht gefunden: $FILE"
  exit 1
fi

# MIME-Typ ermitteln
MIME_TYPE=$(file --mime-type -b "$FILE")
BASENAME=$(basename "$FILE")
EXT="${BASENAME%.*}"
OUTFILE="${EXT}_converted.txt"

echo "🔍 MIME-Typ erkannt: $MIME_TYPE"

# Tool prüfen
MISSING_TOOLS=false
check_tool "file"

# Textformate: direkt übernehmen
if [[ " ${TEXT_MIME_TYPES[*]} " =~ "$MIME_TYPE" ]]; then
  echo "✅ Textdatei erkannt – keine Konvertierung nötig."
  cp "$FILE" "$OUTFILE"

# Codeformate: Markdown-Block erzeugen
elif [[ " ${CODE_MIME_TYPES[*]} " =~ "$MIME_TYPE" ]]; then
  echo "🧠 Quellcode-Datei erkannt – Markdown-Codeblock wird erstellt..."
  LANG="${MIME_TO_LANG[$MIME_TYPE]:-text}"
  {
    echo "\`\`\`$LANG"
    cat "$FILE"
    echo "\`\`\`"
  } >"$OUTFILE"
  bat -pp -l "$LANG" "$FILE"

# PDF
elif [[ "$MIME_TYPE" == "application/pdf" ]]; then
  check_tool "pdftotext"
  pdftotext "$FILE" "$OUTFILE"

# DOC / DOCX / ODT
elif [[ "$MIME_TYPE" == "application/msword" ||
  "$MIME_TYPE" == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ||
  "$MIME_TYPE" == "application/vnd.oasis.opendocument.text" ]]; then
  check_tool "pandoc"
  pandoc "$FILE" -t plain -o "$OUTFILE"

# RTF
elif [[ "$MIME_TYPE" == "application/rtf" ]]; then
  check_tool "unrtf"
  unrtf --text "$FILE" >"$OUTFILE"

# Audio
elif [[ "$MIME_TYPE" == "audio/mpeg" || "$MIME_TYPE" == "audio/wav" ]]; then
  check_tool "whisper"
  whisper "$FILE" --output_format txt --output_dir .
  OUTFILE="${EXT}.txt"

else
  echo "❌ Dieser MIME-Typ wird nicht unterstützt: $MIME_TYPE"
  exit 2
fi

if [ "$MISSING_TOOLS" = true ]; then
  echo "🚫 Bitte installiere die fehlenden Tools und versuche es erneut."
  exit 3
fi

echo "✅ Verarbeitung abgeschlossen. Textdatei: $OUTFILE"
