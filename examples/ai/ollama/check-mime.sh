#!/usr/bin/env bash

# Dateipfad als Argument prüfen
if [ $# -eq 0 ]; then
  echo "⚠️  Bitte gib den Pfad zu einer Datei an."
  exit 1
fi

FILE="$1"

# Prüfen, ob die Datei existiert
if [ ! -f "$FILE" ]; then
  echo "❌ Datei nicht gefunden: $FILE"
  exit 1
fi

# MIME-Typ der Datei ermitteln
MIME_TYPE=$(file --mime-type -b "$FILE")

# Liste erlaubter MIME-Typen
ALLOWED_MIME_TYPES=(
  "text/plain"
  "application/json"
  "application/xml"
  "text/html"
  "text/csv"
  "text/markdown"
  "application/x-yaml"
)

# Prüfung, ob MIME-Typ erlaubt ist
if [[ " ${ALLOWED_MIME_TYPES[@]} " =~ " ${MIME_TYPE} " ]]; then
  echo "✅ Unterstützter MIME-Typ erkannt: $MIME_TYPE"
  echo "🟢 Datei kann direkt verarbeitet werden."
  exit 0
else
  echo "⚠️ Nicht unterstützter MIME-Typ: $MIME_TYPE"
  echo "🔧 Bitte konvertiere die Datei in ein unterstütztes Textformat."
  exit 2
fi
