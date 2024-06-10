#!/usr/bin/env bash

do_something() {
  echo "Ausführung des gewünschten Skripts."
}

# Get the current date and next day's date
current_day=$(date +%d)
current_date=$(date +%Y-%m-%d)
next_day_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)

# Extract the month part from the dates
current_month=$(date -d "$current_date" +%m)
next_day_month=$(date -d "$next_day_date" +%m)

if ((current_day == 1)); then
  echo "Heute ist der erste Tag des Monats."
  do_something
elif ((current_month != next_day_month)); then
  echo "Heute ist der letzte Tag des Monats."
  do_something
fi
