#!/usr/bin/env bash

# Fail on errors (-e), undefined variables (-u) and single failed commands
# within a pipeline (-o pipefail)
set -euo pipefail

# define an array for various purposes
declare -a ARR

# define defaults
verbose=false
nc=false
cron=false
duration=0

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-cr] [-nc] -d seconds arg1 [arg2...]

Script converts given seconds to a more human readable format.

Available options:

-h, --help                       Print this help and exit
-v, --verbose                    Print script debug info
-cr, --cron                      Set cron flag
-nc, --no-colour, --no-color     Disable colors
-d, --secs <seconds>             Parameter seconds
EOF
}

parse_params() {
 local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case "$param" in
      -h | --help)
        usage
        exit 0
        ;;
      -v | --verbose)
        set -x
        verbose=true
        ;;
      -nc | --no-colour | --no-color)
        nc=true
        ;;
      -cr | --cron)
        cron=true
        ;;
      -d | --secs)
        duration="$1"
        shift
        ;;
      *)
        ARR+=("$param")
        ;;
    esac
  done
}

# example function for demonstration purposes
readable_seconds() {
  local secs=$1

  if (( secs < 119 )); then
    printf "%d seconds" "$secs"
  elif (( secs < 7199 )); then
    printf "%d minutes" "$((10#$secs / 60))"
  elif (( secs < 172799 )); then
    printf "%d hours" "$((10#$secs / 3600))"
  else
    printf "%d days" "$((10#$secs / 86400))"
  fi
}

main() {

  [[ $# -lt 1 ]] && {
    usage
    exit 1
  }
  parse_params "$@"
  readable_seconds "$duration"
  exit 0
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
