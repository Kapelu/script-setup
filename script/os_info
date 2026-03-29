#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ OS_Info – Brinda información del sistema.          │
# │ Versión: 4.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 19-02-2026                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'

# Colores
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

C_RESET="\e[0m"
C_TITLE="\e[1;32m"   # Green
C_LABEL="\e[1;33m"  # Yellow
C_STITLE="\e[1;34m"   # Cyan
C_DATA="\e[1;90m"  

TMP_DIR="$(mktemp -d)"

datetime() {
  date +"%d-%m-%Y %H:%M:%S"
}

async_all() {
  {
    source /etc/os-release
    echo "$NAME|$VERSION|$VERSION_ID|$ID_LIKE"
  } > "$TMP_DIR/os" &

  {
    CPU=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d ':' -f2 | xargs)
    CORES=$(nproc)
    echo "$CPU|$CORES"
  } > "$TMP_DIR/cpu" &

  {
    GPU=$(lspci 2>/dev/null | grep -i 'vga\|3d\|2d' | head -n1 | cut -d ':' -f3- | xargs)

    GPU=$(echo "$GPU" \
      | sed -E 's/Corporation//g' \
      | sed -E 's/Core Processor//g' \
      | sed -E 's/Integrated Graphics Controller/Integrated Graphics/g' \
      | sed -E 's/\(rev [^)]+\)//g' \
      | xargs)

    echo "$GPU"
  } > "$TMP_DIR/gpu" &

  {
    PKG=$(dpkg -l 2>/dev/null | grep -c "^ii")
    SNAP=$(snap list 2>/dev/null | tail -n +2 | wc -l)
    echo "$PKG|$SNAP"
  } > "$TMP_DIR/pkg" &

  # Hardware model + firmware
  {
    MODEL=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "N/A")
    VENDOR=$(cat /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null || echo "")
    BIOS=$(cat /sys/devices/virtual/dmi/id/bios_version 2>/dev/null || echo "N/A")
    echo "$VENDOR $MODEL|$BIOS"
  } > "$TMP_DIR/hw" &

  # Software info
  {
    KERNEL=$(uname -r)
    ARCH=$(uname -m)

    if [ "$ARCH" = "x86_64" ]; then
      OS_TYPE="64-bit"
    else
      OS_TYPE="32-bit"
    fi

    GNOME=$(gnome-shell --version 2>/dev/null | awk '{print $3}' || echo "N/A")
    SESSION=${XDG_SESSION_TYPE:-unknown}

    echo "$KERNEL|$OS_TYPE|$GNOME|$SESSION"
  } > "$TMP_DIR/sw" &
}

get() {
  case "$1" in
    user) whoami ;;
    host) hostname ;;
    arch) uname -m ;;
    shell) basename "$SHELL" ;;
    shell_version) "$SHELL" --version | head -n1 | awk '{print $NF}' ;;
    ram) free -h | awk '/Mem:/ {print $3 " / " $2}' ;;
    disk) df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}' ;;

    os_name) cut -d '|' -f1 "$TMP_DIR/os" ;;
    os_version) cut -d '|' -f2 "$TMP_DIR/os" ;;

    cpu) cut -d '|' -f1 "$TMP_DIR/cpu" ;;
    cores) cut -d '|' -f2 "$TMP_DIR/cpu" ;;
    gpu) cat "$TMP_DIR/gpu" ;;
    pkg) cut -d '|' -f1 "$TMP_DIR/pkg" ;;
    snap) cut -d '|' -f2 "$TMP_DIR/pkg" ;;

    hw_model) cut -d '|' -f1 "$TMP_DIR/hw" ;;
    firmware) cut -d '|' -f2 "$TMP_DIR/hw" ;;

    kernel) cut -d '|' -f1 "$TMP_DIR/sw" ;;
    os_type) cut -d '|' -f2 "$TMP_DIR/sw" ;;
    gnome) cut -d '|' -f3 "$TMP_DIR/sw" ;;
    session) cut -d '|' -f4 "$TMP_DIR/sw" ;;
  esac
}

render() {
  echo ""
  echo -e "     ${C_TITLE}$(get user)@$(get host)${C_RESET}"
  echo "     ----------------------"
  echo ""
  echo -e "     ${C_STITLE}Información del hardware${C_RESET}"
	echo -e "     ${C_LABEL}OS:${C_DATA} $(get os_name) $(get os_type)"
  echo -e "     ${C_LABEL}Version:${C_DATA} $(get os_version)"
  #echo -e "     ${C_LABEL}Tipo SO:${C_DATA} "
  echo -e "     ${C_LABEL}Kernel:${C_DATA} $(get kernel)"
  echo -e "     ${C_LABEL}GNOME:${C_DATA} $(get gnome)"
  echo -e "     ${C_LABEL}Session:${C_DATA} $(get session)"
  echo -e "     ${C_LABEL}Shell:${C_DATA} $(get shell) $(get shell_version)"
  echo -e "     ${C_LABEL}Packages:${C_DATA} $(get pkg) (dpkg), $(get snap) (snap)"
  echo ""
  echo -e "     ${C_STITLE}Información del software${C_RESET}"
  echo -e "     ${C_LABEL}Modelo:${C_DATA} $(get hw_model)"
  echo -e "     ${C_LABEL}Firmware:${C_DATA} $(get firmware)"
  echo -e "     ${C_LABEL}CPU:${C_DATA} $(get cpu) ($(get cores))"
  echo -e "     ${C_LABEL}GPU:${C_DATA} $(get gpu)"
  echo -e "     ${C_LABEL}RAM:${C_DATA} $(get ram)"
  echo -e "     ${C_LABEL}Disk:${C_DATA} $(get disk)"
  echo ""
  echo -e "     ${C_TITLE}📅 $(datetime)${C_RESET}"
  echo -e "     ${C_TITLE}⚠️  Info guardada en $HOME/OS_Info.md${C_RESET}"
}

main() {
  clear
  async_all
  wait
  render

  {
  echo "# 🖥️ OS Info"
  echo ""

  echo "## 👤 Usuario"
  echo "- **User:** $(get user)"
  echo "- **Host:** $(get host)"
  echo ""

  echo "## 💿 Información de software"
  echo "- **OS:** $(get os_name) $(get os_type)"
  echo "- **Versión:** $(get os_version)"
  echo "- **Versión del núcleo:** $(get kernel)"
  echo "- **Versión de GNOME:** $(get gnome)"
  echo "- **Sistema de ventanas:** $(get session)"
  echo "- **Shell:** $(get shell) $(get shell_version)"
  echo "- **Paquetes:** $(get pkg) (dpkg), $(get snap) (snap)"
  echo ""

  echo "## ⚙️ Información de hardware"
  echo "- **Modelo de hardware:** $(get hw_model)"
  echo "- **Versión de firmware:** $(get firmware)"
  echo "- **CPU:** $(get cpu) ($(get cores) cores)"
  echo "- **GPU:** $(get gpu)"
  echo "- **RAM:** $(get ram)"
  echo "- **Disk:** $(get disk)"
  echo ""

  echo "---"
  echo "**Fecha de generación:** $(datetime)"
  echo ""

} > "$HOME/OS_Info.md"

echo ""
read -n 1 -s -r -p " Presioná cualquier tecla para continuar..."
echo ""
clear
rm -rf "$TMP_DIR"

  rm -rf "$TMP_DIR"
}

main