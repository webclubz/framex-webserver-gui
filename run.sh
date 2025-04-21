#!/bin/bash

while true; do
CHOICE=$(zenity --list --title="Grmatics Panel" --height=600 --width=400 --column="Action" \
"➕ Create New Project (from name)" \
"🧠 Add Existing Project (from folder)" \
"🌐 Show Active Projects" \
"🌀 Switch PHP Version" \
"🧰 Manage Services" \
"🗑️ Delete Project" \
"❌ Exit")

case "$CHOICE" in
    "➕ Create New Project (from name)")
        ./add-vhost-entered-name.sh
        ;;
    "🧠 Add Existing Project (from folder)")
        ./add-vhost-from-folder.sh
        ;;
    "🌐 Show Active Projects")
        active=$(ls /etc/apache2/sites-enabled | grep ".test.conf" | sed 's/.conf//')
        zenity --info --title="Active .test Projects" --text="🟢 Active:\n$active"
        ;;
    "🌀 Switch PHP Version")
        ./php-version-switcher.sh
        ;;
    "🧰 Manage Services")
    ./webserver-services.sh
    ;;
    "🗑️ Delete Project")
        ./delete-project.sh
        ;;
    "❌ Exit")
        break
        ;;
    *)
        zenity --warning --text="No valid option selected."
        ;;
esac
done
