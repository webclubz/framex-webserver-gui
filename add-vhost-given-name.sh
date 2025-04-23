#!/bin/bash
TITLE="➕ Create New Project"
USER_HOME="/home/framex"
SITES_DIR="$USER_HOME/Sites"
APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

. ./lib/safe_exit.sh

PROJECT=$(zenity --entry --title="$TITLE" --text="🔤 Enter a name for the new project:")
if [ -z "$PROJECT" ]; then
    zenity --warning --title="$TITLE" --text="⚠️ No project name provided. Returning to main menu." --width=400
    exit 0
fi

PROJECT_DIR="$SITES_DIR/$PROJECT"
DOMAIN="$PROJECT.test"
CONF_FILE="$APACHE_CONF_DIR/$DOMAIN.conf"

# Ask for public folder
zenity --question \
    --title="Public Folder" \
    --text="🗂️ Do you want to create a <b>public/</b> folder inside the project?\n\nIf yes, it will be used as the DocumentRoot." \
    --ok-label="Yes" --cancel-label="No"

if [ $? -eq 0 ]; then
    DOC_ROOT="$PROJECT_DIR/public"
    mkdir -p "$DOC_ROOT"
    echo "<?php echo 'Hello from $DOMAIN (public)'; ?>" > "$DOC_ROOT/index.php"
else
    DOC_ROOT="$PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
    echo "<?php echo 'Hello from $DOMAIN'; ?>" > "$PROJECT_DIR/index.php"
fi

# Set permissions
chown -R $USER:$USER "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"
chmod o+x "$USER_HOME"
chmod o+rx "$SITES_DIR" "$PROJECT_DIR"

# Create Apache VirtualHost
if [ ! -f "$CONF_FILE" ]; then
    sudo bash -c "cat > $CONF_FILE" <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $DOC_ROOT

    <Directory $DOC_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    sudo a2ensite "$DOMAIN.conf"
fi

# Add to /etc/hosts
if ! grep -q "$DOMAIN" "$HOSTS_FILE"; then
    echo "127.0.0.1   $DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null
fi

# Reload Apache
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

safe_exit "Project '$PROJECT' created successfully! Opening browser: http://$DOMAIN" 1.5

