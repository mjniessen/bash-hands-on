#!/bin/bash

MODEL="llama3.2:latest"
TEMPERATURE=0.2
API_URL="http://localhost:11434/api/generate"
PROMPT="What is 7 * 48? You may use CALL:calculator(...) to solve it."

while true; do
  RESPONSE=$(curl -s -X POST $API_URL \
    -H "Content-Type: application/json" \
    -d '{
      "model": "'"$MODEL"'",
      "prompt": "'"$PROMPT"'",
      "stream": false,
      "temperature": '"$TEMPERATURE"'
    }' | jq -r '.response')

  echo -e "\n[Model Response]: $RESPONSE"

  # Look for tool call pattern: CALL: calculator(expression)
  if [[ "$RESPONSE" =~ CALL:calculator\((.*)\) ]]; then
    EXPRESSION="${BASH_REMATCH[1]}"
    echo "[Detected tool call]: calculator($EXPRESSION)"

    # Use 'bc' for safe math evaluation
    RESULT=$(echo "$EXPRESSION" | bc -l)
    PROMPT="Result: $RESULT"
  else
    echo -e "\n[Final Output]: $RESPONSE"
    break
  fi
done
