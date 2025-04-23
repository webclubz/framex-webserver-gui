#!/bin/bash

TITLE="🧩 PHP Modules Manager"
. ./lib/safe_exit.sh

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

ALL_MODULES=$(find /etc/php/$PHP_VERSION/mods-available -name "*.ini" | sed 's#.*/##' | sed 's/.ini$//')
ENABLED_MODULES=$(php -m)

# Build checklist for Zenity
CHECKLIST=""
for module in $ALL_MODULES; do
    if echo "$ENABLED_MODULES" | grep -q -i "^$module$"; then
        CHECKLIST="$CHECKLIST TRUE $module "
    else
        CHECKLIST="$CHECKLIST FALSE $module "
    fi
done

SELECTED=$(zenity --list \
    --title="$TITLE" \
    --text="✅ Select PHP modules to enable:\n(Checked = active)" \
    --checklist \
    --column="Enabled" \
    --column="Module" \
    --width=500 --height=600 \
    $CHECKLIST
)

if [ -z "$SELECTED" ]; then
    zenity --info --title="$TITLE" --text="⚠️ No modules selected. Returning to main menu."
    safe_exit "No changes made." 1
fi

IFS="|" read -r -a TOGGLE <<< "$SELECTED"

for mod in $ALL_MODULES; do
    is_enabled=$(echo "$ENABLED_MODULES" | grep -i "^$mod$")

    if printf '%s\n' "${TOGGLE[@]}" | grep -q -w "$mod"; then
        if [ -z "$is_enabled" ]; then
            echo "✅ Enabling: $mod"
            sudo phpenmod "$mod"
        fi
    else
        if [ ! -z "$is_enabled" ]; then
            echo "❌ Disabling: $mod"
            sudo phpdismod "$mod"
        fi
    fi
done

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

safe_exit "PHP modules updated and Apache restarted." 1.5
