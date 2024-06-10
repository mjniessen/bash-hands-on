#!/usr/bin/env bash

do_something() {
  echo "Ausführung des gewünschten Skripts."
}

# Get the current date and next day's date
current_date=$(date +%Y-%m-%d)
next_day_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)

# Extract the month part from the dates
current_month=$(date -d "$current_date" +%m)
next_day_month=$(date -d "$next_day_date" +%m)

# Check if the months are different
if ((current_month != next_day_month)); then
  echo "Heute ist der letzte Tag des Monats."
  do_something
else
  echo "Heute ist nicht der letzte Tag des Monats."
fi
