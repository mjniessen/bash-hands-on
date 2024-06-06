#!/usr/bin/env bash

# Get the current day of the week
current_day="$(date +%A)"

# Define the source and destination directories
source_dir="../parts/"
backup_dir="../backup/${current_day}"

# Create the backup directory if it does not exist
mkdir -p "$backup_dir"

# Perform the backup using rsync
rsync -a --delete "$source_dir" "$backup_dir"

echo "Backup of 'parts/' completed for $current_day."
