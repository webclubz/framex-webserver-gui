#!/bin/bash

AVAILABLE_VERSIONS=("7.4" "8.1" "8.2" "8.3" "8.4")
SELECTED=$(zenity --list --title="Switch PHP Version" --height=600 --width=400 --column="Available PHP Versions" "${AVAILABLE_VERSIONS[@]}")

if [ -z "$SELECTED" ]; then
    zenity --warning --text="No version selected."
    exit 1
fi

PHP_PACKAGE="php$SELECTED"
MOD_PACKAGE="libapache2-mod-php$SELECTED"
EXTENSIONS=( "cli" "common" "mysql" "xml" "mbstring" "curl" )

IS_INSTALLED=$(dpkg -l | grep "$PHP_PACKAGE")

if [ -z "$IS_INSTALLED" ]; then
    zenity --question --text="PHP $SELECTED is not installed. Install it now?"
    if [ $? -ne 0 ]; then
        exit 0
    fi

    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update

    # Εγκατάσταση PHP και των extensions
    INSTALL_PACKAGES="$PHP_PACKAGE $MOD_PACKAGE"
    for ext in "${EXTENSIONS[@]}"; do
        INSTALL_PACKAGES="$INSTALL_PACKAGES php$SELECTED-$ext"
    done

    sudo apt install -y $INSTALL_PACKAGES
fi

# Switch Apache module
sudo a2dismod $(ls /etc/apache2/mods-enabled | grep -Eo 'php[0-9]+\.[0-9]+' | head -n1)
sudo a2enmod "php$SELECTED"
sudo systemctl restart apache2

# Switch CLI version
sudo update-alternatives --set php /usr/bin/php$SELECTED
sudo update-alternatives --set phar /usr/bin/phar$SELECTED
sudo update-alternatives --set phar.phar /usr/bin/phar.phar$SELECTED
sudo update-alternatives --set phpize /usr/bin/phpize$SELECTED
sudo update-alternatives --set php-config /usr/bin/php-config$SELECTED

CURRENT=$(php -v | head -n1)
zenity --info --text="✅ Switched to $CURRENT"
