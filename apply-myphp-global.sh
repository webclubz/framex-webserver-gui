#!/bin/bash

TITLE="🛠️ Manage Global myphp.ini"
PHP_VERSIONS=$(ls /etc/php)

. ./lib/safe_exit.sh

CHOICE=$(zenity --list \
  --title="$TITLE" \
  --text="📦 What do you want to do with <b>myphp.ini</b>?" \
  --radiolist --column="Select" --column="Action" \
  TRUE "✅ Apply globally (Apache & CLI)" \
  FALSE "🧹 Remove override from all PHP versions" \
  --width=450 --height=250)

[ -z "$CHOICE" ] && safe_exit "No action selected." 0.8

if [[ "$CHOICE" == "✅ Apply globally (Apache & CLI)" ]]; then
    if [ ! -f "./myphp.ini" ]; then
        zenity --error --title="$TITLE" --text="❌ myphp.ini not found in current folder!" --width=400
        exit 1
    fi

    for ver in $PHP_VERSIONS; do
        for sapi in apache2 cli; do
            TARGET_DIR="/etc/php/$ver/$sapi/conf.d"
            if [ -d "$TARGET_DIR" ]; then
                sudo ln -sf "$(pwd)/myphp.ini" "$TARGET_DIR/zzz-framex.ini"
            fi
        done
    done

    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl restart apache2

    safe_exit "myphp.ini applied globally." 1.5

else
    for ver in $PHP_VERSIONS; do
        for sapi in apache2 cli; do
            FILE="/etc/php/$ver/$sapi/conf.d/zzz-framex.ini"
            if [ -f "$FILE" ]; then
                sudo rm -f "$FILE"
            fi
        done
    done

    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl restart apache2

    safe_exit "myphp.ini override removed from all PHP versions." 1.5
fi
