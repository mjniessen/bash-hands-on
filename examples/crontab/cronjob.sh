#!/usr/bin/env bash

LOCKFILE="/tmp/$(basename ${0}).lock"

main() {

  echo 'Script is doing some stuff!'
  sleep 10
  # the last line of your template MUST be commented out or be deleted
  # exit 0
}

if ! (return 0 2>/dev/null); then
  # check if a LOCKFILE exists and process is still running
  if [ -e "$LOCKFILE" ] && kill -0 "$(<"$LOCKFILE")"; then
    echo "Script is already running."
    exit 1
  fi

  # write PID to LOCKFILE
  trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
  echo $$ >"$LOCKFILE"

  # do the script's main logic
  main "$@"

  # remove LOCKFILE
  rm -f "$LOCKFILE"
  trap - INT TERM EXIT
  exit 0
fi
