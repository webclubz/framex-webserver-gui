#!/bin/bash

USER_HOME="/home/framex"
SITES_DIR="$USER_HOME/Sites"
PROJECT_NAME="localhost"
PROJECT_DIR="$SITES_DIR/$PROJECT_NAME"

echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing Apache, PHP, MariaDB, phpMyAdmin..."
sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip phpmyadmin unzip -y

echo "🧰 Enabling Apache modules..."
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "📁 Creating Sites folder..."
mkdir -p "$PROJECT_DIR"
echo "<?php echo 'Hello from $PROJECT_NAME.test'; ?>" | sudo tee "$PROJECT_DIR/index.php"

echo "🔐 Setting permissions..."
sudo chown -R framex:framex "$SITES_DIR"
chmod -R 755 "$SITES_DIR"
chmod o+x "$USER_HOME"
chmod o+rx "$SITES_DIR" "$PROJECT_DIR"

echo "🌐 Creating virtual host for $PROJECT_NAME.test..."
VHOST_FILE="/etc/apache2/sites-available/$PROJECT_NAME.test.conf"
sudo bash -c "cat > $VHOST_FILE" <<EOF
<VirtualHost *:80>
    ServerName $PROJECT_NAME.test
    DocumentRoot $PROJECT_DIR

    <Directory $PROJECT_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "🧩 Enabling site and updating hosts file..."
sudo a2ensite "$PROJECT_NAME.test.conf"
echo "127.0.0.1   $PROJECT_NAME.test" | sudo tee -a /etc/hosts

echo "🔄 Reloading Apache..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

echo "✅ Done! Visit http://$PROJECT_NAME.test to test your setup!"
