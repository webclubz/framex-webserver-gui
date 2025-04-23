#!/bin/bash

TITLE="🌀 PHP Version Switcher"
AVAILABLE_VERSIONS=("8.1" "8.2" "8.3" "8.4")

. ./lib/safe_exit.sh

SELECTED=$(zenity --list \
  --title="$TITLE" \
  --text="📦 Select PHP version to activate:" \
  --height=500 --width=400 \
  --column="Available Versions" "${AVAILABLE_VERSIONS[@]}")

if [ -z "$SELECTED" ]; then
    zenity --warning --title="$TITLE" --text="⚠️ No version selected. Operation cancelled."
    safe_exit "Returning..." 1
fi

PHP_PACKAGE="php$SELECTED"
MOD_PACKAGE="libapache2-mod-php$SELECTED"
EXTENSIONS=( "cli" "common" "mysql" "xml" "mbstring" "curl" )

IS_INSTALLED=$(dpkg -l | grep "$PHP_PACKAGE")

if [ -z "$IS_INSTALLED" ]; then
    zenity --question --title="$TITLE" \
      --text="ℹ️ PHP $SELECTED is not installed.\nDo you want to install it now?" \
      --ok-label="Yes" --cancel-label="No"

    if [ $? -ne 0 ]; then
        safe_exit "Operation cancelled." 1
    fi

    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update

    INSTALL_PACKAGES="$PHP_PACKAGE $MOD_PACKAGE"
    for ext in "${EXTENSIONS[@]}"; do
        INSTALL_PACKAGES="$INSTALL_PACKAGES php$SELECTED-$ext"
    done

    sudo apt install -y $INSTALL_PACKAGES
fi

# Switch Apache PHP module
CURRENT_MOD=$(ls /etc/apache2/mods-enabled | grep -Eo 'php[0-9]+\.[0-9]+' | head -n1)
if [ ! -z "$CURRENT_MOD" ]; then
    sudo a2dismod "$CURRENT_MOD"
fi

sudo a2enmod "php$SELECTED"

# Restart Apache properly
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

# Switch CLI PHP version
sudo update-alternatives --set php /usr/bin/php$SELECTED
sudo update-alternatives --set phar /usr/bin/phar$SELECTED
sudo update-alternatives --set phar.phar /usr/bin/phar.phar$SELECTED
sudo update-alternatives --set phpize /usr/bin/phpize$SELECTED
sudo update-alternatives --set php-config /usr/bin/php-config$SELECTED

CURRENT=$(php -v | head -n1)
safe_exit "Switched to $CURRENT" 1.5
