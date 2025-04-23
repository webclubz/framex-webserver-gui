#!/bin/bash

TITLE="🔐 Manage MySQL User"
MYSQL_CMD="sudo mysql"

. ./lib/safe_exit.sh

# Detect MySQL or MariaDB
IS_MARIADB=$($MYSQL_CMD -V | grep -i mariadb > /dev/null && echo "yes" || echo "no")

function create_user_sql() {
  local user=$1
  local host=$2
  local pass=$3

  if [ "$IS_MARIADB" == "yes" ]; then
    echo "CREATE USER IF NOT EXISTS '$user'@'$host' IDENTIFIED BY '$pass';"
  else
    echo "CREATE USER IF NOT EXISTS '$user'@'$host' IDENTIFIED WITH mysql_native_password BY '$pass';"
  fi
}

function update_password_sql() {
  local user=$1
  local host=$2
  local pass=$3

  if [ "$IS_MARIADB" == "yes" ]; then
    echo "ALTER USER '$user'@'$host' IDENTIFIED BY '$pass';"
  else
    echo "ALTER USER '$user'@'$host' IDENTIFIED WITH mysql_native_password BY '$pass';"
  fi
}

ACTION=$(zenity --list \
  --title="$TITLE" \
  --text="📦 What do you want to do?" \
  --radiolist --column="Select" --column="Action" \
  TRUE "➕ Create User" \
  FALSE "🗑️ Delete User" \
  FALSE "🔑 Update Password" \
  --width=450 --height=300)

[ -z "$ACTION" ] && safe_exit "No action selected." 0.8

if [[ "$ACTION" == "➕ Create User" ]]; then
    USERNAME=$(zenity --entry --title="$TITLE" --text="👤 New username:")
    [ -z "$USERNAME" ] && safe_exit "Cancelled." 1

    PASSWORD=$(zenity --entry --title="$TITLE" --hide-text --text="🔑 Password:")
    [ -z "$PASSWORD" ] && safe_exit "Cancelled." 1

    DB=$(zenity --entry --title="$TITLE" --text="🗄️ Database (or * for all):")
    [ -z "$DB" ] && safe_exit "Cancelled." 1

    ADVANCED=$(zenity --list \
      --title="$TITLE" \
      --text="💡 Allow login from any host?" \
      --checklist --column="Select" --column="Option" \
      FALSE "Allow access from %")

    SQL="$(create_user_sql "$USERNAME" "localhost" "$PASSWORD")
GRANT ALL PRIVILEGES ON $DB.* TO '$USERNAME'@'localhost';"

    if echo "$ADVANCED" | grep -q "Allow access from %"; then
        SQL+="
$(create_user_sql "$USERNAME" "%" "$PASSWORD")
GRANT ALL PRIVILEGES ON $DB.* TO '$USERNAME'@'%';"
    fi

    SQL+="
FLUSH PRIVILEGES;
"

    echo "$SQL" | $MYSQL_CMD

    if [ $? -eq 0 ]; then
        safe_exit "User '$USERNAME' created successfully." 1.5
    else
        zenity --error --title="$TITLE" --text="❌ Failed to create user."
        exit 1
    fi

elif [[ "$ACTION" == "🗑️ Delete User" ]]; then
    USERNAME=$(zenity --entry --title="$TITLE" --text="👤 Username to delete:")
    [ -z "$USERNAME" ] && safe_exit "Cancelled." 1

    zenity --question \
      --title="$TITLE - Confirm Deletion" \
      --text="❗ Are you sure you want to delete user '<b>$USERNAME</b>'?" \
      --ok-label="Yes, delete" --cancel-label="Cancel"

    if [ $? -ne 0 ]; then
        safe_exit "Cancelled." 1
    fi

    SQL="
DROP USER IF EXISTS '$USERNAME'@'localhost';
DROP USER IF EXISTS '$USERNAME'@'%';
FLUSH PRIVILEGES;
"

    echo "$SQL" | $MYSQL_CMD

    if [ $? -eq 0 ]; then
        safe_exit "User '$USERNAME' deleted." 1.5
    else
        zenity --error --title="$TITLE" --text="❌ Failed to delete user."
        exit 1
    fi

elif [[ "$ACTION" == "🔑 Update Password" ]]; then
    USERNAME=$(zenity --entry --title="$TITLE" --text="👤 Username:")
    [ -z "$USERNAME" ] && safe_exit "Cancelled." 1

    PASSWORD=$(zenity --entry --title="$TITLE" --hide-text --text="🔑 New Password:")
    [ -z "$PASSWORD" ] && safe_exit "Cancelled." 1

    SQL="$(update_password_sql "$USERNAME" "localhost" "$PASSWORD")
$(update_password_sql "$USERNAME" "%" "$PASSWORD")
FLUSH PRIVILEGES;"

    echo "$SQL" | $MYSQL_CMD

    if [ $? -eq 0 ]; then
        safe_exit "Password for '$USERNAME' updated." 1.5
    else
        zenity --error --title="$TITLE" --text="❌ Failed to update password."
        exit 1
    fi
fi
