#!/usr/bin/env bash

while read -ra ARR; do
	# skip lines not starting with 'ii'
	[[ "${ARR[0]}" != "ii" ]] && continue
	echo "${ARR[1]} ${ARR[2]}"
done <<<"$(dpkg -l)"
