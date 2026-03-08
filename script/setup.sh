#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ cerrar-sesion - Script para cerrar la sesión       │
# │ Versión: 2.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 10/08/2023                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'

VERSION="3.0"
USUARIO=$(whoami)
HOSTNAME=$(hostname)
FECHA=$(date "+%d-%m-%Y")
HORA=$(date "+%H:%M:%S")

APT_BASE=( wget gpg apt-transport-https chrome-gnome-shell gnome-browser-connector font-manager net-tools )

APT_DEV_TOOLS=( lsd neofetch dialog git curl build-essential usb-creator-gtk gparted )

SNAP_DEV_TOOLS=( proton-pass proton-mail sublime-text jdownloader2 vlc telegram-desktop )
clear
### ───────────────────────────────
### COLORES ANSI UNIFICADOS
### ───────────────────────────────
declare -A COLOR=(
  [reset]='\e[0m'
  [bold]='\e[1m'
  [italic]='\e[3m'
  [warn]='\e[31;47m'
  [warn_alt]='\e[31;40m'
  [green]='\e[32m'
  [yellow]='\e[33m'
  [blue]='\e[34m'
  [magenta]='\e[35m'
  [cyan]='\e[36m'
  [gray]='\e[90m'
)

########################################
# DETECCIÓN DE DISTRO
########################################

detect_distro() {

  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
  else
    echo "No se puede detectar la distro"
    exit 1
  fi

  case "$ID" in
    ubuntu|debian|linuxmint)
      DISTRO=$ID
      ;;
    *)
      echo "⚠️  WARNING"
      echo "Este script solo soporta:"
      echo "Ubuntu / Debian / Linux Mint"
      echo "Distro detectada: $ID"
      exit 1
      ;;
  esac

}

### ───────────────────────────────
### FUNCIONES ÚTILES
### ───────────────────────────────
print_banner() {
  local msg="$1"
  echo -e "${COLOR[green]}════════════════════════════════════════════════════${COLOR[reset]}"
  echo -e "$msg"
  echo -e "${COLOR[green]}════════════════════════════════════════════════════${COLOR[reset]}"
}
sleep 3

command_exists() { command -v "$1" >/dev/null 2>&1; }

pkg_installed() { dpkg -s "$1" >/dev/null 2>&1; }

snap_installed() { snap list "$1" >/dev/null 2>&1; }

alerta_critica() {
  for i in {1..6}; do
    echo -ne "${COLOR[warn]}❌ ERROR EN LÍNEA $1${COLOR[reset]}\r"
    sleep 0.4
    echo -ne "${COLOR[warn_alt]}❌ ERROR EN LÍNEA $1${COLOR[reset]}\r"
    sleep 0.4
  done
  echo
}
trap 'alerta_critica $LINENO; exit 1' ERR

########################################
# INSTALADOR APT
########################################

install_apt() {

local to_install=()

for pkg in "$@"; do
  if pkg_installed "$pkg"; then
	clear
    echo -e "${COLOR[magenta]}✔ $pkg ya instalado${COLOR[reset]}"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
clear
  echo -e "${COLOR[green]}📦 Instalando: ${to_install[*]}${COLOR[reset]}"
  sudo apt install -y "${to_install[@]}"
fi

}

########################################
# INSTALADOR SNAP
########################################

install_snap() {

local pkg="$1"
local flag="${2:-}"

if snap_installed "$pkg"; then
clear
  echo -e "${COLOR[magenta]}✔ $pkg ya instalado${COLOR[reset]}"

else
clear
  echo -e "${COLOR[green]}$📦 Instalando snap: $pkg${COLOR[reset]}"
  sudo snap install "$pkg" $flag
fi

}

########################################
# UPDATE SISTEMA
########################################

system_update() {
	clear
	echo -e "${COLOR[green]}🔄 Actualizando sistema${COLOR[reset]}"
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt full-upgrade -y
}

########################################
# LIMPIEZA
########################################

system_cleanup() { sudo apt autoremove -y; sudo apt clean; }

########################################
# FIREFOX
########################################

remove_firefox() {

sudo snap remove --purge firefox || true
sudo apt purge -y firefox || true
rm -rf ~/.mozilla || true

}

########################################
# BRAVE
########################################

install_brave() {

if command_exists brave-browser; then
clear
  echo ""
    echo -e "${COLOR[magenta]}✔ Brave ya instalado${COLOR[reset]}"
  return
fi
clear

echo -e "${COLOR[green]}📦 Instalando Brave${COLOR[reset]}"

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" \
| sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update -y

install_apt brave-browser -y

}

########################################
# GOOGLE CHROME
########################################

install_chrome() {

if command_exists google-chrome; then
clear
    echo -e "${COLOR[magenta]}✔ Chrome ya instalado${COLOR[reset]}"
  
  return
fi
clear

echo -e "${COLOR[green]}📦 Instalando Google Chrome${COLOR[reset]}"

tmp="/tmp/chrome.deb"

wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$tmp"

sudo dpkg -i "$tmp" || sudo apt -f install -y

rm -f "$tmp"

}

########################################
# PROTON VPN
########################################

install_protonvpn() {

if pkg_installed proton-vpn-gnome-desktop; then
clear
  
    echo -e "${COLOR[magenta]}✔ ProtonVPN ya instalado${COLOR[reset]}"

  return
fi
clear

echo -e "${COLOR[green]}📦  Instalando ProtonVPN${COLOR[reset]}"

tmp="/tmp/protonvpn.deb"

wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb -O "$tmp"

sudo dpkg -i "$tmp"

sudo apt update -y

install_apt \
proton-vpn-gnome-desktop \
gnome-keyring \
libayatana-appindicator3-1

rm -f "$tmp"

echo "✔ ProtonVPN instalado"

}

########################################
# VSCODE
########################################

install_vscode() {

if command_exists code; then
clear
  
    echo -e "${COLOR[magenta]}✔ VSCode ya instalado${COLOR[reset]}"
	
  return
fi
clear
echo -e "${COLOR[green]}📦  Instalando VSCode${COLOR[reset]}"


wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
| gpg --dearmor > packages.microsoft.gpg

sudo install -D -m 644 packages.microsoft.gpg \
/etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update

install_apt code

}

########################################
# NODE
########################################

install_node() {

if command_exists node; then
clear
    echo -e "${COLOR[magenta]}✔ Node ya instalado${COLOR[reset]}"
  
  return
fi
clear

echo -e "${COLOR[green]}📦  Instalando NVM${COLOR[reset]}"

curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts

npm install -g pnpm yarn

curl -fsSL https://bun.sh/install | bash

}

########################################
# INSTALAR SNAP TOOLS
########################################

install_snap_tools() {

for pkg in "${SNAP_DEV_TOOLS[@]}"; do

  if [[ "$pkg" == "sublime-text" ]]; then
    install_snap "$pkg" "--classic"
  else
    install_snap "$pkg"
  fi

done

}

########################################
# INSTALAR APT TOOLS
########################################

install_apt_tools() {

install_apt "${APT_DEV_TOOLS[@]}"

}

########################################
# SSH
########################################

setup_ssh() {

if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  echo "✔ SSH ya configurado"
  return
fi

read -rp "Email SSH: " EMAIL

ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""

eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

cat "$HOME/.ssh/id_ed25519.pub"

}

########################################
# EJECUCIÓN
########################################
clear
main() {
START=$SECONDS

install_btn

detect_distro

system_update

install_apt "${APT_BASE[@]}"

system_cleanup

remove_firefox

########################################
# INSTALACIÓN PARALELA
########################################

install_brave &
install_chrome &
install_vscode &
install_protonvpn &
install_node &
install_apt_tools &
install_snap_tools &

wait

#setup_ssh

system_cleanup

ELAPSED=$(( SECONDS - START ))
HORAS=$((ELAPSED / 3600))
MINUTOS=$(( (ELAPSED % 3600) / 60 ))
SEGUNDOS=$((ELAPSED % 60))

clear
print_banner "  🎉 Secuencia Post-Install completada con éxito!!!
	Usuario: $USUARIO
	Host: $HOSTNAME
	Fecha: $FECHA
	Hora de inicio: $HORA
	Hora de fin   : $(date '+%H:%M:%S')
	Tiempo total  : ${HORAS}h:${MINUTOS}m:${SEGUNDOS}s"

}

main