#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ Install - Script para comenzar la instalación.     │
# │ Versión: 2.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 06/03/2026                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'

USER_NAME=$(whoami)
HOME_DIR=$HOME
DESKTOP_DIR=$(xdg-user-dir DESKTOP)
TMP_DIR="/tmp/kape-setup-$RANDOM"
REPO="https://github.com/Kapelu/kape-setup.git"
LOG_FILE="$HOME_DIR/setup-kape.log"
green='\e[32m'
reset='\e[0m'
LOG="$HOME/post-install.log"

log() {
    echo -e "\033[0;32m✅ $1\033[0m"
    echo "$1" >> "$LOG"
}

detect_distro(){

 if [ ! -f /etc/os-release ]; then
  log "Sistema no soportado"
  exit 1
 fi

 source /etc/os-release

 case "$ID" in
   ubuntu|debian|linuxmint|pop)
     log "Distribución detectada: $ID"
   ;;
   *)
     log "Distribución no soportada"
     exit 1
 esac
}

check_git(){

 if ! command -v git >/dev/null; then
  log "Instalando git"
  sudo apt update
  sudo apt install -y git
 fi
}

backup_bashrc(){

 if [ -f "$HOME_DIR/.bashrc" ]; then
   cp "$HOME_DIR/.bashrc" "$HOME_DIR/.bashrc.backup.$(date +%s)"
   log "Backup de .bashrc creado"
 fi
}

clone_repo(){

 log "Clonando repositorio"

 git clone -b main "$REPO" "$TMP_DIR"
}

copy_scripts(){

 mkdir -p "$HOME_DIR/script"

 cp "$TMP_DIR/script/"* "$HOME_DIR/script/"

 chmod +x "$HOME_DIR/script/"*
}

copy_config(){

 cp "$TMP_DIR/config/.bashrc" "$HOME_DIR/.bashrc"

 cp "$TMP_DIR/config/protect-main.json" "$HOME_DIR/"
}

create_desktop(){

 mkdir -p "DESKTOP_DIR"

cat <<EOF > "DESKTOP_DIR/btn_log.desktop"
[Desktop Entry]
Name=Logout
Comment=Cierra sesión con barra visual de 15 segundos
Exec=gnome-terminal --geometry=45x8 --hide-menubar -- bash -c "/home/$USER_NAME/script/btn-log.sh"
Icon=system-log-out
Terminal=false
Type=Application
Categories=Utility;
EOF

cat <<EOF > "DESKTOP_DIR/btn_shd.desktop"
[Desktop Entry]
Name=Apagar
Comment=Apaga la computadora con barra visual de 15 segundos
Exec=gnome-terminal --geometry=45x8 --hide-menubar -- bash -c "/home/$USER_NAME/script/btn-shd.sh"
Icon=system-shutdown
Terminal=false
Type=Application
Categories=System;
EOF

cat <<EOF > "DESKTOP_DIR/btn_sus.desktop"
[Desktop Entry]
Name=Suspender
Comment=Suspender la máquina con barra visual de 15 segundos
Exec=gnome-terminal --geometry=45x8 --hide-menubar -- bash -c "/home/$USER_NAME/script/btn-sus.sh"
Icon=system-suspend
Terminal=false
Type=Application
Categories=Utility;
EOF
}

system_update(){ sudo apt update -y; sudo apt upgrade -y; sudo apt full-upgrade -y; }

system_cleanup(){

 sudo apt autoremove -y
 sudo apt clean
}

cleanup(){ rm -rf "$TMP_DIR"; }

run_setup(){

printf "${green}📦 ¿Desea ejecutar setup.sh? (s/n): ${reset}"
read RESP


 if [ "$RESP" = "s" ]; then
   bash "$HOME_DIR/script/setup.sh"
 else
   system_update
   system_cleanup
 fi
}

main(){

 log "Iniciando Secuencia Post-Install setup-kape"

 detect_distro
 check_git
 clone_repo
 copy_scripts
 backup_bashrc
 copy_config
 create_desktop
 run_setup
 cleanup

}
main