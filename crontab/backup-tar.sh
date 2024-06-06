#!/usr/bin/env bash

# Get the current day of the week
current_day="$(date +%A)"

# Define the source and destination directories
source_dir="../parts/"
backup_dir="../backup"

backup_file="${current_day}.tar.xz"

# Create the backup tar file (gzip)
# tar -czf "${backup_dir}/${current_day}.tar.gz" -C "$source_dir" .

# Create the backup tar file (xz)
tar -cJf "${backup_dir}/$backup_file" -C "$source_dir" .

# Update the symlink to the latest backup
ln -sfn "$backup_file" "${backup_dir}/latest.tar.xz"

echo "Backup of 'parts/' completed for $current_day."
