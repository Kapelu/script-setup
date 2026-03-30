#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: XX/XX/XXXX                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'
clear

source "$BASE_DIR/script/install_apt"
source "$BASE_DIR/script/install_snap"

install_snap() {
  log_info "📦 Instalando herramientas snap..."
  install_snap "${SNAP_TOOLS[@]}"
}

install_apt(){
	log_info "📦 Instalando paquetes apt..."
  install_apt "${APT_TOOLS[@]}"
}

cleanup() {
  local dir="${DEST_DIR:-}"

  # 1. Variable no vacía
  [[ -n "$dir" ]] || return

  # 2. Debe existir y ser directorio
  [[ -d "$dir" ]] || return

  # 3. No permitir rutas peligrosas
  case "$dir" in
    "/"|"/home"|"$HOME"|"/root"|"")
      echo "❌ Ruta peligrosa detectada: $dir" >&3
      return
      ;;
  esac

  # 4. Debe estar dentro de /temp o /tmp (whitelist)
  [[ "$dir" == "$HOME/temp/"* || "$dir" == "/tmp/"* ]] || {
    echo "❌ Ruta fuera de zona segura: $dir" >&3
    return
  }

  # 5. Borrar
  rm -rf "$dir"
}

update() {
  log_info " 🔧 Actualizando sistema..."
	sudo apt-get remove imagemagick -y &&
  sudo apt-get update &&
  sudo apt-get full-upgrade -y &&
  sudo apt-get autoremove -y &&
  sudo apt-get autoclean -y &&
  sudo apt-get clean
  log_ok "Sistema actualizado"
}
