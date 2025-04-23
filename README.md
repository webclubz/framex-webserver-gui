# 🧭 Framex Webserver Dev Panel (Shell + Zenity Edition)

![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![Shell](https://img.shields.io/badge/shell-bash-blue)
![UI](https://img.shields.io/badge/ui-zenity-brightgreen)
![License](https://img.shields.io/badge/license-free%20for%20devs-orange)

> ⚙️ A clean, fast, and styled Linux GUI tool for managing your local webserver stack (Apache, PHP, MySQL) using Bash & Zenity.

---

## 📌 Features

- 🔧 Create Apache virtualhosts (auto `.test` domains)
- 📂 Add existing folders as web projects
- 🌐 View enabled vhosts (via `/etc/apache2/sites-enabled`)
- 🌀 Switch PHP versions dynamically (8.1 → 8.4+)
- 🧩 Enable/disable PHP modules via GUI
- 🛠 Apply or remove global `myphp.ini` overrides
- 🧰 Manage local services (Apache, MariaDB, PHP-FPM)
- 🗑️ Delete project + cleanup hosts + vhost file
- 🔐 Create, delete, update MySQL users (localhost + optional `%`)
- 💬 Smooth UX with animated feedback (`safe_exit.sh`)

---

## 🖼 UI Preview

> 📷 Add your screenshots here, e.g.:

![Screenshot](assets/framex-gui.jpg)

---

## 🛠 Installation

```bash
git clone https://github.com/yourname/framex-webserver
cd framex-webserver
chmod +x *.sh
./start-gui.sh
![framex-gui](https://github.com/user-attachments/assets/efa378fe-ad8e-4ee8-8d2a-0ae508cff2f5)
