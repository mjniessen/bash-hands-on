#!/usr/bin/env bash

# Fail on errors (-e), undefined variables (-u) and single failed commands
# within a pipeline (-o pipefail)
set -euo pipefail

main() {

  #
  # Insert your code here
  #

  exit 0
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
