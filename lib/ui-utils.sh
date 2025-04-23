function zen_info() {
  zenity --info --title="$1" --text="$2" --width=500 --height=120
}
function zen_error() {
  zenity --error --title="$1" --text="$2" --width=500 --height=120
}
function zen_warn() {
  zenity --warning --title="$1" --text="$2" --width=500 --height=120
}
