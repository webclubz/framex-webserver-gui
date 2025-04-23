#!/bin/bash

TITLE="🧰 Services Manager"
. ./lib/safe_exit.sh

ACTION=$(zenity --list --title="$TITLE" \
  --height=400 --width=400 \
  --text="📦 Select an action for your local services:" \
  --column="Action" \
  "🟢 Start All Services" \
  "🛑 Stop All Services" \
  "🔁 Restart All Services" \
  "🔍 Check Service Status")

[ -z "$ACTION" ] && safe_exit "Returning to main menu..." 1

SERVICES=("apache2" "mariadb")

# Add PHP-FPM instances dynamically
for fpm in $(systemctl list-units --type=service | grep php | grep fpm | awk '{print $1}' | cut -d. -f1); do
    SERVICES+=("$fpm")
done

case "$ACTION" in
    "🟢 Start All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl start "$svc"
        done
        safe_exit "All services started." 1.5
        ;;

    "🛑 Stop All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl stop "$svc"
        done
        safe_exit "All services stopped." 1.5
        ;;

    "🔁 Restart All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl restart "$svc"
        done
        safe_exit "All services restarted." 1.5
        ;;

    "🔍 Check Service Status")
        output=""
        for svc in "${SERVICES[@]}"; do
            status=$(systemctl is-active "$svc")
            case $status in
                active) icon="🟢" ;;
                inactive) icon="🔴" ;;
                failed) icon="❌" ;;
                *) icon="⚠️" ;;
            esac
            output+="$icon $svc: $status\n"
        done

        zenity --text-info --title="$TITLE - Status Report" \
            --width=500 --height=400 \
            --filename=<(echo -e "$output")
        ;;
esac
