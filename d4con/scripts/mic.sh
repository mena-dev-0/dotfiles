#!/bin/bash

prev_state="inactive"

while true; do
  # Check for active audio streams using the "source" (input, aka mic)
  mic_active=$(pactl list source-outputs | grep -c "Source Output")

  if [[ "$mic_active" -gt 0 && "$prev_state" == "inactive" ]]; then
    notify-send "Microphone In Use"
    prev_state="active"
  elif [[ "$mic_active" -eq 0 && "$prev_state" == "active" ]]; then
    notify-send "Microphone Off"
    prev_state="inactive"
  fi

  sleep 2
done

