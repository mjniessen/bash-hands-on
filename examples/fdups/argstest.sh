#!/usr/bin/env bash

echo -e "Script   \t: \e[37;3m\e[2m$(basename "${0^}")\e[0m"
echo -e " Arguments \t: \e[37;3m\e[2m$#\e[0m"

for ((i=1; i<=$#; i++)); do
  echo -e " Argument \$$i\t: \e[37;3m\e[2m${!i}\e[0m"
done
