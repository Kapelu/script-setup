#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ Nombre – Descripción                               │
# │ Versión: X.X                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: XX/XX/XXXX                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'
clear

SNAP_TOOLS=( 
	jdownloader2 
	vlc 
	)

# Verifica si snap existe
# ------------------------------
snap_installed() {
  command -v snap &>/dev/null
}

# Verifica si snapd está activo
# ------------------------------
snap_service_ready() {
  systemctl is-active snapd &>/dev/null
}

# Instala y prepara snapd
# ------------------------------
ensure_snapd() {
  if snap_installed; then
    log_ok "snap ya disponible"
    return 0
  fi

  log_warn "snap no encontrado, instalando snapd..."

  retry sudo apt-get install -y snapd

  log_run "Habilitando snapd..."
  sudo systemctl enable --now snapd

  log_run "Esperando inicialización de snapd..."

  # Espera activa hasta que snap responda
  local i=0
  while ! snap list &>/dev/null; do
    sleep 2
    ((i++))
    if (( i > 15 )); then
      log_error "snapd no respondió"
      exit 1
    fi
  done

  log_ok "snapd listo"
}

# Verifica si snap está instalado
# ------------------------------
is_snap_installed() {
  snap list | awk '{print $1}' | grep -qx "$1"
}

# Instalador inteligente snap
# ------------------------------
install_snap() {
  ensure_snapd

  local to_install=()

  for arg in "$@"; do
    [[ "$arg" == -* ]] && continue

    local raw="$arg"
    local pkg="$arg"
    local channel=""
    local classic=""

    # Detectar canal
    if [[ "$pkg" == *=* ]]; then
      channel="--channel=${pkg#*=}"
      pkg="${pkg%%=*}"
    fi

    # Detectar classic
    if [[ "$pkg" == *:classic ]]; then
      classic="--classic"
      pkg="${pkg%%:*}"
    fi

    if is_snap_installed "$pkg"; then
      log_ok "$pkg ya está instalado"
    else
      to_install+=("$pkg|$channel|$classic")
    fi
  done

  if [ ${#to_install[@]} -eq 0 ]; then
    log_info "Nada para instalar (snap)"
    return 0
  fi

  for item in "${to_install[@]}"; do
    IFS="|" read -r pkg channel classic <<< "$item"

    log_run "Instalando snap: $pkg $channel $classic"
    retry sudo snap install "$pkg" $channel $classic
  done
}