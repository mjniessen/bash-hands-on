#!/bin/bash

# Konfiguration
OLLAMA_URL="http://localhost:11434"

# Funktion: Prüfen, ob Ollama erreichbar ist
check_ollama() {
  curl -s --head --request GET "$OLLAMA_URL/api/tags" | grep "HTTP/1.1 200" >/dev/null
  return $?
}

# Ollama prüfen
if ! check_ollama; then

  ollama serve >/tmp/ollama_server.log 2>&1 &
  OLLAMA_PID=$!

  for i in {1..10}; do
    sleep 1
    if check_ollama; then
      break
    fi
  done

  if ! check_ollama; then
    echo "Fehler: Ollama konnte nicht gestartet werden."
    kill $OLLAMA_PID 2>/dev/null
    exit 1
  fi
fi

# Lokale Modelle abrufen
local_models=$(curl -s -X GET "$OLLAMA_URL/api/tags" | jq -r '.models[].name')

# Geladene Modelle abrufen
loaded_models=$(curl -s -X GET "$OLLAMA_URL/api/ps" | jq -r '.models[].name')

# Liste vorbereiten
model_list=""
for model in $local_models; do
  if echo "$loaded_models" | grep -q "^$model$"; then
    model_list+="$model [LOADED]"$'\n'
  else
    model_list+="$model"$'\n'
  fi
done

# Auswahl mit fzf
echo "$model_list" | fzf --multi --header="Wähle ein oder mehrere Modelle aus:" --prompt="Modelle> " --height=20

# Hinweis: Die Auswahl wird einfach auf stdout ausgegeben.
# Wenn du weiterverarbeiten willst (z.B. Modelle laden oder prompten), kannst du die Auswahl in eine Variable lesen:
# selected_models=$(echo "$model_list" | fzf --multi --header="..." --prompt="..." --height=20)
