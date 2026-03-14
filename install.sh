#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ setup-kapelu installer completo Ubuntu             │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 14/03/2026                                  │
# ╚════════════════════════════════════════════════════╝

set -Eeuo pipefail
IFS=$'\n\t'

GREEN='\e[32m'
RESET='\e[0m'

USER_NAME=$(whoami)
HOME_DIR="$HOME"
DESKTOP_DIR=$(xdg-user-dir DESKTOP)
TMP_DIR="/tmp/kape-setup-$RANDOM"
REPO="https://github.com/Kapelu/kape-setup.git"

log() { echo -e "${GREEN}✅ $1${RESET}"; }

# 1️⃣ Detectar distro
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
  else
    echo "❌ No se puede detectar la distro"
    exit 1
  fi
  case "$ID" in
    ubuntu|debian|linuxmint|pop)
      log "Distribución soportada: $ID"
      ;;
    *)
      echo "❌ Distro no soportada: $ID"
      exit 1
      ;;
  esac
}

# 2️⃣ Actualizar sistema
system_update() {
  log "Actualizando sistema..."
  sudo apt update -y
  sudo apt upgrade -y
  sudo apt install -y curl git build-essential xdg-utils
}

# 3️⃣ Instalar NVM + Node LTS
install_node() {
  log "Instalando NVM..."
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  log "Instalando Node LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'

  log "Node $(node -v) y npm $(npm -v) listos"
}

# 4️⃣ Instalar setup-kapelu globalmente
install_kapelu() {
  log "Instalando setup-kapelu globalmente..."
  npm install -g setup-kapelu
  if command -v kapelu >/dev/null 2>&1; then
    log "setup-kapelu instalado correctamente"
  else
    echo "❌ Error instalando setup-kapelu"
    exit 1
  fi
}

# 5️⃣ Clonar repositorio temporal
clone_repo() {
  log "Clonando repositorio..."
  git clone -b main "$REPO" "$TMP_DIR"
}

# 6️⃣ Copiar scripts y dar permisos
copy_scripts() {
  mkdir -p "$HOME_DIR/script"
  cp -r "$TMP_DIR/script/." "$HOME_DIR/script/"
  find "$HOME_DIR/script" -type f -exec chmod +x {} \;
}

# 7️⃣ Copiar configuración
copy_config() {
  cp "$TMP_DIR/config/.bashrc" "$HOME_DIR/.bashrc"
  cp "$TMP_DIR/config/protect-main.json" "$HOME_DIR/"
}

# 8️⃣ Crear accesos directos en escritorio
create_desktop() {
  mkdir -p "$DESKTOP_DIR"
  DATA=(
    "log|Logout|Cierra sesión en 10 segundos|system-log-out"
    "shd|Apagar|Apaga la PC en 10 segundos|system-shutdown"
    "sus|Suspender|Suspende la PC en 10 segundos|system-suspend"
  )
  for row in "${DATA[@]}"; do
    IFS="|" read -r id name comment icon <<< "$row"
    file="$DESKTOP_DIR/btn_${id}.desktop"
    cat <<EOF > "$file"
[Desktop Entry]
Name=$name
Comment=$comment
Exec=gnome-terminal --geometry=45x8 --hide-menubar -- bash -c "/home/$USER_NAME/script/btn-${id}.sh"
Icon=$icon
Terminal=false
Type=Application
Categories=Utility;
EOF
    chmod +x "$file"
    gio set "$file" metadata::trusted true
  done
  killall -q nautilus 2>/dev/null || true
}

# 9️⃣ Ejecutar setup.sh
run_setup() {
  FILE="$HOME_DIR/script/setup.sh"
  if [ ! -f "$FILE" ]; then
    echo "❌ setup.sh no encontrado"
    return 1
  fi
  chmod +x "$FILE"
  "$FILE"
}

#  🔟 Limpieza
cleanup() {
  rm -rf "$TMP_DIR"
}

# ────────────── Main ──────────────
main() {
  detect_distro
  system_update
  install_node
  install_kapelu
  clone_repo
  copy_scripts
  copy_config
  create_desktop
  run_setup
  cleanup
  log "🎉 Secuencia Post-Install completada con éxito"
}

main