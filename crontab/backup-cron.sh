#!/usr/bin/env bash

SCRIPT_NAME=$(basename "$0")
LOCKFILE="/tmp/${SCRIPT_NAME}.lock"
FULL_PATH="$HOME/Projects/knowledge/crontab"

main() {
  local current_day source_dir
  local backup_dir backup_file backup_size

  # Get the current day of the week
  current_day="$(date +%A)"

  # Define the source and destination directories
  source_dir="${FULL_PATH}/parts/"
  backup_dir="${FULL_PATH}/backup"
  backup_file="${current_day}.tar.xz"

  # Create the backup tar file (xz)
  tar -cJf "${backup_dir}/$backup_file" -C "$source_dir" .

  # Update the symlink to the latest backup
  ln -sfn "$backup_file" "${backup_dir}/latest.tar.xz"

  # Get the size of the backup file
  backup_size=$(stat -c%s "${backup_dir}/${backup_file}")

  # Send a message to syslog
  logger -t backup_script "Backup '$backup_file' created ($backup_size bytes)."
}

if ! (return 0 2>/dev/null); then
  # check if a LOCKFILE exists and process is still running
  if [ -e "$LOCKFILE" ] && kill -0 "$(<"$LOCKFILE")"; then
    logger -t backup_scipt "Script is already/still running."
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
