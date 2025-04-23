#!/bin/bash

TITLE="🧭 Framex Webserver Panel"

while true; do
CHOICE=$(zenity --list \
    --title="$TITLE" \
    --text="📦 Select an action:" \
    --height=600 --width=420 \
    --column="Action" \
    "➕ Create New Project (from name)" \
    "📂 Add Existing Project (from folder)" \
    "🌐 View Active Projects" \
    "🌀 Switch PHP Version" \
    "🧩 Manage PHP Modules" \
    "🛠️ Apply/Remove myphp.ini (Global)" \
    "🧰 View Services Status" \
    "🗑️ Delete Project" \
    "🔐 Manage MySQL Users" \
    "❌ Exit")

case "$CHOICE" in
    "➕ Create New Project (from name)")
        ./add-vhost-given-name.sh
        ;;
    "📂 Add Existing Project (from folder)")
        ./add-vhost-existing-folder.sh
        ;;
    "🌐 View Active Projects")
        active=$(ls /etc/apache2/sites-enabled | grep ".test.conf" | sed 's/.conf//')
        zenity --info --title="Active .test Projects" --text="🟢 Currently Enabled Projects:\n\n$active" --width=400
        ;;
    "🌀 Switch PHP Version")
        ./php-version-switcher.sh
        ;;
    "🧩 Manage PHP Modules")
        ./manage-php-modules.sh
        ;;
    "🛠️ Apply/Remove myphp.ini (Global)")
        ./apply-myphp-global.sh
        ;;
    "🧰 View Services Status")
        ./services-status.sh
        ;;
    "🗑️ Delete Project")
        ./delete-project.sh
        ;;
    "🔐 Manage MySQL Users")
        ./manage-mysql-user.sh
        ;;
    "❌ Exit")
        break
        ;;
    *)
        zenity --warning --title="$TITLE" --text="⚠️ No valid option selected." --width=400
        ;;
esac
done
