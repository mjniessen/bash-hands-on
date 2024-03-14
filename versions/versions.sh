#!/usr/bin/env bash

# Fail on errors (-e), undefined variables (-u) and single failed commands
# within a pipeline (-o pipefail)
set -euo pipefail

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

main() {
  # Save possiple given arguments
  ARGS=("$@")

  OUTFILE="installed_software.csv"

  #
  # Your code has to be placed here.
  #

  print_csv_head > "${OUTFILE}"
  parse_dpkg >> "${OUTFILE}"

  exit 0
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
