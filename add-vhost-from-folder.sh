#!/bin/bash

USER_HOME="/home/framex"
SITES_DIR="$USER_HOME/Sites"
APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

echo "🔍 Scanning $SITES_DIR for projects..."

for dir in "$SITES_DIR"/*/; do
    [ -d "$dir" ] || continue
    site_name=$(basename "$dir")
    conf_file="$APACHE_CONF_DIR/$site_name.test.conf"

    if [ -f "$conf_file" ]; then
        echo "🟡 $site_name.test already has a virtual host. Skipping..."
        continue
    fi

    # Έλεγχος για public folder
    if [ -d "$dir/public" ]; then
        doc_root="$dir/public"
    else
        doc_root="$dir"
    fi

    echo "🛠️ Creating virtual host for $site_name.test (DocRoot: $doc_root)..."

    sudo bash -c "cat > $conf_file" <<EOF
<VirtualHost *:80>
    ServerName $site_name.test
    DocumentRoot $doc_root

    <Directory $doc_root>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

    echo "📡 Adding $site_name.test to hosts file..."
    echo "127.0.0.1   $site_name.test" | sudo tee -a "$HOSTS_FILE" > /dev/null

    echo "🔗 Enabling site..."
    sudo a2ensite "$site_name.test.conf"

done

echo "🔄 Reloading Apache..."
sudo systemctl reload apache2

echo "✅ Done! All virtual hosts are set up!"
