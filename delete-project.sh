#!/bin/bash

APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

# Βρες όλα τα .test projects
project_list=$(ls $APACHE_CONF_DIR | grep ".test.conf" | sed 's/.conf//')

# Zenity: επιλογή project
PROJECT=$(zenity --list --title="Delete Project" --height=600 --width=400 --column="Projects" $project_list)

if [ -z "$PROJECT" ]; then
    zenity --info --text="No project selected. Exiting."
    exit 1
fi

DOMAIN="$PROJECT"
CONF_FILE="$APACHE_CONF_DIR/$DOMAIN.conf"

# Επιβεβαίωση
zenity --question --title="Confirm Deletion" --text="Are you sure you want to delete '$DOMAIN'?"
if [ $? -ne 0 ]; then
    zenity --info --text="Deletion cancelled."
    exit 1
fi

# Διαγραφή από Apache
sudo a2dissite "$DOMAIN.conf"
sudo rm -f "$CONF_FILE"

# Αφαίρεση από /etc/hosts
sudo sed -i "/$DOMAIN/d" "$HOSTS_FILE"

# Reload Apache
sudo systemctl reload apache2

zenity --info --text="🗑️ Project '$DOMAIN' has been deleted."
