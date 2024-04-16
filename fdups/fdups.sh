#!/usr/bin/env bash

######################################################################
# @author      : Maurice-Jörg Nießen (post@mjniessen.com)
# @file        : fdups
# @created     : Dienstag Apr 16, 2024 08:06:02 CEST
#
# @description : find duplicates
######################################################################

# Fail on errors (-e), undefined variables (-u) and single failed commands
# within a pipeline (-o pipefail)
set -euo pipefail

_fdups() {
  local min_size="${1:-10000}"

  find -not -empty -type f -size "+${min_size}" -printf "%-30s\t\"%h/%f\"\n" \
    | sort -rn -t$'\t' | uniq -w30 -D \
    | cut -f2 -d $'\t' | xargs md5sum \
    | sort | uniq -w32 -D | uniq -w32 --group
}

main() {
  # Save possiple given arguments
  ARGS=("$@")

  cd /srv/downloads/manual
  _fdups "$@"

  exit 0
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
