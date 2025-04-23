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

![framex-gui](https://github.com/user-attachments/assets/efa378fe-ad8e-4ee8-8d2a-0ae508cff2f5)

---

## 🛠 Installation

```bash
git clone https://github.com/yourname/framex-webserver
cd framex-webserver
chmod +x *.sh
./start-gui.sh

```
📦 Requirements
Linux (tested on Ubuntu 22.04 / 24.04)

- Apache2
- PHP (8.1 – 8.4+ via ondrej/php PPA)
- MariaDB or MySQL
- Zenity (sudo apt install zenity)

---

💡 What is coming for Next Versions
- .desktop launcher for app menu integration
- .deb installer or AppImage portability
- YAD UI version (tabs, icons, wizard)
- Dark mode / theme toggle
- Autostart service status checker

## ⚠️ Disclaimer

This is a personal project, originally developed for local development use.  
Feel free to use, modify, or extend it to suit your own workflow.

However, by using this tool, you accept that you do so **entirely at your own risk**.  
The creator of this project holds **no responsibilityfor any damage, data loss,  
misconfiguration, or system-level changes that may occur as a result of its usage.** 

**Always review the code and understand what each script does before running it on your system.**
