#!/usr/bin/env bash

ollama run "$(ollama list | awk 'NR > 1 { print $1 }' | fzf)"
