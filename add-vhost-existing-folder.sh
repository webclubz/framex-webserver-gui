#!/bin/bash

TITLE="📂 Add Existing Projects"
USER_HOME="/home/framex"
SITES_DIR="$USER_HOME/Sites"
APACHE_CONF_DIR="/etc/apache2/sites-available"
HOSTS_FILE="/etc/hosts"

. ./lib/safe_exit.sh

found_projects=0
log=""

for dir in "$SITES_DIR"/*/; do
    [ -d "$dir" ] || continue
    site_name=$(basename "$dir")
    conf_file="$APACHE_CONF_DIR/$site_name.test.conf"

    if [ -f "$conf_file" ]; then
        log+="⚠️  $site_name.test already has a virtual host. Skipping...\n"
        continue
    fi

    # Check for public folder
    if [ -d "$dir/public" ]; then
        doc_root="$dir/public"
    else
        doc_root="$dir"
    fi

    # Create vhost
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

    # Add to /etc/hosts
    if ! grep -q "$site_name.test" "$HOSTS_FILE"; then
        echo "127.0.0.1   $site_name.test" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi

    # Enable site
    sudo a2ensite "$site_name.test.conf"
    found_projects=$((found_projects + 1))
    log+="✅ $site_name.test added (DocRoot: $doc_root)\n"
done

# Reload Apache
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart apache2

if [ "$found_projects" -eq 0 ]; then
    zenity --info --title="$TITLE" --text="ℹ️ No new folders found without a virtual host." --width=450
else
    zenity --text-info \
        --title="$TITLE - Summary" \
        --width=500 --height=400 \
        --filename=<(echo -e "$log")
fi

safe_exit "All virtual hosts processed successfully." 1.5
