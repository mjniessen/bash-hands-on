#!/usr/bin/env bash

print_csv_head() {
	echo -e "package\tversion\tarchitecture\tdescription"
}

parse_dpkg() {
	while read -ra ARR; do
		# skip lines not starting with 'ii'
		[[ "${ARR[0]}" != "ii" ]] && continue

		local package="${ARR[1]}"
		local version="${ARR[2]}"
		local architecture="${ARR[3]}"
		local description="${ARR[*]:4}"

		echo -e "${package}\t${version}\t${architecture}\t${description@Q}"
	done <<<"$(dpkg -l)"
}

print_csv_head
parse_dpkg
