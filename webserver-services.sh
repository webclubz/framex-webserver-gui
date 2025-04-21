#!/bin/bash

ACTION=$(zenity --list --title="Grmatics Services Panel" --height=600 --width=400 --column="Action" \
"Start All Services" \
"Stop All Services" \
"Restart All Services" \
"Check Status")

if [ -z "$ACTION" ]; then
    exit 0
fi

SERVICES=("apache2" "mariadb")

# Αν έχεις PHP-FPM:
for fpm in $(systemctl list-units --type=service | grep php | grep fpm | awk '{print $1}' | cut -d. -f1); do
    SERVICES+=("$fpm")
done

case "$ACTION" in
    "Start All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl start "$svc"
        done
        zenity --info --text="🟢 All services started!"
        ;;
    "Stop All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl stop "$svc"
        done
        zenity --info --text="🛑 All services stopped!"
        ;;
    "Restart All Services")
        for svc in "${SERVICES[@]}"; do
            sudo systemctl restart "$svc"
        done
        zenity --info --text="🔁 All services restarted!"
        ;;
    "Check Status")
        output=""
        for svc in "${SERVICES[@]}"; do
            status=$(systemctl is-active "$svc")
            output+="$svc: $status\n"
        done
        zenity --info --title="Service Status" --text="$output"
        ;;
esac
