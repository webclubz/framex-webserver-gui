#!/bin/bash

TITLE="🗑️ Delete Project"
APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

. ./lib/safe_exit.sh

# List .test projects
project_list=$(ls "$APACHE_CONF_DIR" | grep ".test.conf" | sed 's/.conf//')

PROJECT=$(zenity --list \
  --title="$TITLE" \
  --height=500 --width=400 \
  --text="🔍 Select a project to delete:" \
  --column="Projects" $project_list)

if [ -z "$PROJECT" ]; then
    zenity --info --title="$TITLE" --text="⚠️ No project selected. Returning to main menu."
    safe_exit "Cancelled." 1
fi

DOMAIN="$PROJECT"
CONF_FILE="$APACHE_CONF_DIR/$DOMAIN.conf"

# Confirm deletion
zenity --question \
  --title="$TITLE - Confirmation" \
  --text="❗ Are you sure you want to delete '<b>$DOMAIN</b>'?\nThis will disable and remove the Apache configuration." \
  --ok-label="Yes, delete" --cancel-label="Cancel"

if [ $? -ne 0 ]; then
    zenity --info --title="$TITLE" --text="🚫 Deletion cancelled."
    safe_exit "No changes made." 1
fi

# Disable and remove vhost
sudo a2dissite "$DOMAIN.conf"
sudo rm -f "$CONF_FILE"

# Remove from /etc/hosts
sudo sed -i "/$DOMAIN/d" "$HOSTS_FILE"

# Reload Apache
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

safe_exit "Project '$DOMAIN' was deleted successfully." 1.5
