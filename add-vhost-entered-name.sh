#!/bin/bash

USER_HOME="/home/framex"
SITES_DIR="$USER_HOME/Sites"
APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

# Ζητάμε όνομα project
PROJECT=$(zenity --entry --title="New Project" --text="Enter project name:")

# Αν ο χρήστης πατήσει cancel ή άφησε κενό
if [ -z "$PROJECT" ]; then
    zenity --warning --text="No project name provided. Exiting."
    exit 1
fi

PROJECT_DIR="$SITES_DIR/$PROJECT"
DOMAIN="$PROJECT.test"
CONF_FILE="$APACHE_CONF_DIR/$DOMAIN.conf"

# Δημιουργία φακέλου και index.php αν δεν υπάρχει
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    echo "<?php echo 'Hello from $DOMAIN'; ?>" | tee "$PROJECT_DIR/index.php" > /dev/null
fi

# Δικαιώματα
chown -R $USER:$USER "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"
chmod o+x "$USER_HOME"
chmod o+rx "$SITES_DIR" "$PROJECT_DIR"

# Apache Virtual Host
if [ ! -f "$CONF_FILE" ]; then
    sudo bash -c "cat > $CONF_FILE" <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $PROJECT_DIR

    <Directory $PROJECT_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    sudo a2ensite "$DOMAIN.conf"
fi

# /etc/hosts entry
if ! grep -q "$DOMAIN" "$HOSTS_FILE"; then
    echo "127.0.0.1   $DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null
fi

# Apache reload
sudo systemctl reload apache2

zenity --info --text="✅ Project '$PROJECT' created!\nVisit http://$DOMAIN"
