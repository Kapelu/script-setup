#!/bin/bash
# ╔════════════════════════════════════════════════════╗
# │ setup – Instalación y configuraciones Post-Install │
# │ Versión: 3.5                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 16/10/2023                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# ╚════════════════════════════════════════════════════╝


blue="\e[0;36m"
green="\e[0;32m"
red_bg="\e[1;41m"
yellow="\e[0;33m"
close_color="\e[0m"

show_log() {
  echo -e "\n-----> $1"
}
show_info_log() {
  echo -e "\n$blue-----> $1 $close_color"
}
show_success_log() {
  echo -e "\n$green-----> $1 $close_color"
}
show_warning_log() {
  echo -e "\n$yellow-----> $1 $close_color"
}
show_error_log() {
  echo -e "\n$red_bg ERROR: $1 $close_color"
}

show_info_input() {
  echo -ne "\n$blue-----> $1 $close_color"
}
USUARIO=$(whoami)
HOSTNAME=$(hostname)
FECHA=$(date "+%d-%m-%Y")
HORA=$(date "+%H:%M:%S")
bgris='\033[40m'
verde='\033[33m'
amarillo='\033[34m'
azul='\033[35m'
n='\033[1m'
reset='\033[0m'
#echo "⬇️ Descargando..."
#echo "📦 Instalando..."
#echo "🔍 Corrigiendo dependencias si es necesario..."
#echo "⬆️ Asegurando última versión..."

clear
echo -e ""
echo -e "$bgris$verde══════════════════════════════════════════════════════════════════$reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris                Bienvenido $amarillo$USUARIO                        $reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris        Iniciando secuencia Post-Install en $verde$HOSTNAME                $reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris           Fecha: $azul$FECHA             Hora: $azul$HORA           $reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris$verde══════════════════════════════════════════════════════════════════$reset"
sleep 3

echo ""
echo ""
echo "🔧 Actualización del sistema e instalando dependencias necesarias..."
sudo apt update -y
sudo apt install snapd -y
sudo apt install curl -y
sudo apt install wget -y
sudo apt dialogue -y
sudo apt install --fix-missing -y
sudo apt upgrade --allow-downgrades -y
sudo apt full-upgrade --allow-downgrades -y
sudo apt-get update -y
sudo apt-get install -y libappindicator1 wget
sudo apt install -f
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean
sleep 5

echo ""
echo ""
echo "📦 Instalando Brave..."
sudo apt install curl;
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list;
sudo apt update;
sudo apt install -y brave-browser;
echo ""
echo "✅ Brave ha sido instalado correctamente."
sleep 3

echo ""
echo ""
echo "📦 Instalando Google Chrome..."
wget -c --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
sudo apt-get upgrade -y google-chrome-stable
sudo rm -f google-chrome-stable_current_amd64.deb
echo ""
echo "✅ Google Chrome ha sido instalado correctamente."
sleep 3

echo ""
echo ""
echo "📦 Desinstalando Firefox Mozilla..."
sudo apt update -y
sudo snap remove --purge firefox -y
sudo apt remove --autoremove firefox -y
sudo apt-get purge firefox -y 
sudo rm -rf ~/.mozilla -y
sudo apt-get update -y
sudo apt -y upgrade
echo "✅ Firefox Mozilla ha sido desinstalado correctamente."
sleep 3


echo ""
echo ""
echo "📦 Instalando Node..."
sudo snap install curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".
npm install -g npm@11.2.0
echo "✅ Node ha sido instalado correctamente."
echo ""
node -v; npm -v;
sleep 5

echo ""
echo ""
echo "📦 Instalando Git..."
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt install -y git
echo "✅ git ha sido instalado correctamente."
sleep 3

echo ""
echo ""
echo "📦 Instalando VSCode..."
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt -y update
sudo apt install -y code
# Nodemon
npm install -g nodemon
npm install -g loopback-cli
echo "✅ VSCode ha sido instalado correctamente."
sleep 3

echo "📦 Instalando App de Sistema..."
echo ""
echo ""
echo ""
sudo apt install -y wget
wget -c --show-progress https://repo.protonvpn.com/debian/public_key.asc | sudo tee /etc/apt/trusted.gpg.d/protonvpn.asc
echo "deb [signed-by=/etc/apt/trusted.gpg.d/protonvpn.asc] https://repo.protonvpn.com/debian stable main" | sudo tee /etc/apt/sources.list.d/protonvpn.list
sudo apt -y update
sudo apt -y install protonvpn
echo "✅ Proton VPN ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install proton-pass
echo "✅ Proton Pass ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install proton-mail
echo "✅ Proton Mail ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt-get install -y chrome-gnome-shell
echo "✅ Chrome-Gnome-Shell ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt-get -y install gnome-browser-connector
echo "✅ Gnome-Browser-Connector ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install proton-pass
echo "✅ Proton Pass ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install proton-mail
echo "✅ Proton Mail ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt install -y font-manager
echo "✅ Font-Manager ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt install -y net-tools
echo "✅ Net-Tools ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install sublime-text --classic
echo "✅ Sublime Text ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt install -y usb-creator-gtk
echo "✅ USB-Creator ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo apt install -y gparted
echo "✅ GParted ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install jdownloader2
echo "✅ Jdownloader2 ha sido instalado correctamente."
echo ""
echo ""
echo ""
sudo snap install vlc
echo "✅ VLC ha sido instalado correctamente."
echo ""
echo ""
echo ""
echo ""
sudo snap install telegram-desktop
echo "✅ Telegram-Desktop ha sido instalado correctamente."
echo ""
echo ""
echo ""
#sudo add-apt-repository -y ppa:teejee2008/timeshift
#sudo apt-get install -y timeshift
sleep 3

echo "⬆️ Asegurando última versión..."
sudo apt update -y
sudo apt install --fix-missing -y
sudo apt upgrade --allow-downgrades -y
sudo apt full-upgrade --allow-downgrades -y
echo ""
echo ""
sleep 3

echo " LIMPIANDO SISTEMA..."
sudo apt install -f
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean
echo ""
echo ""
sleep 3

clear
HORA2=$(date "+%H:%M:%S")
IFS=: read -ra hms1 <<< "$HORA"
IFS=: read -ra hms2 <<< "$HORA2"
segundos_hora1=$((10#${hms1[0]} * 3600 + 10#${hms1[1]} * 60 + 10#${hms1[2]}))
segundos_hora2=$((10#${hms2[0]} * 3600 + 10#${hms2[1]} * 60 + 10#${hms2[2]}))
diferencia_segundos=$((segundos_hora2 - segundos_hora1))
HORAS=$((diferencia_segundos / 3600))
diferencia_segundos_restantes=$((diferencia_segundos % 3600))
MINUTOS=$((diferencia_segundos_restantes / 60))
SEGUNDOS=$((diferencia_segundos_restantes % 60))
clear
echo -e ""
echo -e "$bgris$verde══════════════════════════════════════════════════════════════════$reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris                 Felicidades $amarillo$USUARIO                      $reset"  
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris     La secuencia Post-Install en $verde$HOSTNAME$reset$bgris fue un ÉXITO             $reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris     Fecha: $azul$FECHA                                            $reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris         Hora de inicio : $azul$HORA                                $reset"
echo -e "$bgris         HORA de fin    : $azul$HORA2                                $reset"
echo -e "$bgris     $verde TIEMPO DE EJECUCIÓN$bgris:$n$azul$HORAS:$MINUTOS:$SEGUNDOS                                  $reset"
echo -e "$bgris                                                                  $reset"
echo -e "$bgris$verde══════════════════════════════════════════════════════════════════$reset"
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris                                                                  $reset" 
echo -e "$bgris$verde          $n$azul Proceder a crear llaves SSH...                         $reset"
echo -e "$bgris                                                                  $reset" 
echo -e ""
