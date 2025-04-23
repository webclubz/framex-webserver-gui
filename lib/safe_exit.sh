#!/bin/bash

# SAFE EXIT with animated progress + OK dialog
function safe_exit() {
    local message="${1:-Operation completed.}"
    local delay="${2:-1.5}"  # Time between 100% and next dialog

    (
        echo "10"
        sleep 0.3
        echo "30"
        sleep 0.4
        echo "60"
        sleep 0.4
        echo "85"
        sleep 0.4
        echo "100"
        sleep "$delay"
    ) | zenity --progress \
        --title="⏳ Please Wait..." \
        --text="Processing...\n\nAlmost done..." \
        --percentage=0 \
        --auto-close \
        --width=420 --height=130

    # OK dialog after progress completes
sleep 0.1
zenity --info \
  --title="✅ Done" \
  --text="✔️ $message\n\nClick OK to return." \
  --width=420 --height=130

    exit 0
}
