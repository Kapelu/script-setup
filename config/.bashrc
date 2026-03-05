#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ .bashrc – Configuración de entorno personal        │
# │ Versión: 3.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# │ Fecha: 16/02/2026                                  │
# ╚════════════════════════════════════════════════════╝

# Variables para cachear info de PWD, gestor y git branch
# =============================================================================
__LAST_PWD=""
__PKG_MANAGER=""
__GIT_BRANCH=""
# Definir carpeta única
#-----------------------------------------
SCRIPT_DIR="$HOME/script"

# Crear si no existe
#-----------------------------------------
[ -d "$SCRIPT_DIR" ] || mkdir -p "$SCRIPT_DIR"

# Añadir al PATH solo si no está ya
#-----------------------------------------
case ":$PATH:" in
  *":$SCRIPT_DIR:"*) ;;
  *) export PATH="$PATH:$SCRIPT_DIR" ;;
esac

# Hacer ejecutables los existentes en script
#-----------------------------------------
find "$SCRIPT_DIR" -type f -exec chmod +x {} \;

# Vigilar nuevos archivos para hacerlos ejecutables automáticamente
# =============================================================================
if command -v inotifywait >/dev/null 2>&1 && [ -z "$__SCRIPTS_WATCH_STARTED" ]; then
  export __SCRIPTS_WATCH_STARTED=1
  inotifywait -m -e create --format '%f' "$SCRIPT_DIR" 2>/dev/null |
  while IFS= read -r file; do
    chmod +x "$SCRIPT_DIR/$file"
  done &
fi

# Función que busca recursivamente hacia arriba desde el directorio actual
# =============================================================================
find_package_json_upwards() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    [ -f "$dir/package.json" ] && { echo "$dir/package.json"; return; }
    dir=$(dirname "$dir")
  done
}

# Función que detecta el gestor de paquetes basado en package.json o archivos lock
# =============================================================================
detect_package_manager() {
  local pkg_json manager dir="$PWD"

  pkg_json=$(find_package_json_upwards)
  if [ -n "$pkg_json" ]; then
    manager=$(grep '"packageManager"' "$pkg_json" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' | cut -d@ -f1)
    [ -n "$manager" ] && { echo "$manager"; return; }
  fi

  while [ "$dir" != "/" ]; do
    [ -f "$dir/pnpm-lock.yaml" ] && { echo "pnpm"; return; }
    [ -f "$dir/yarn.lock" ] && { echo "yarn"; return; }
    [ -f "$dir/package-lock.json" ] && { echo "npm"; return; }
    dir=$(dirname "$dir")
  done

  echo "npm"
}

# Función que instala pnpm globalmente si detecta un pnpm-lock.yaml pero no encuentra pnpm en el PATH 
# =============================================================================
ensure_pnpm() {
  [ ! -x "$(command -v pnpm)" ] && [ -f pnpm-lock.yaml ] && {
    echo "📦 pnpm no está instalado. Instalando globalmente..."
    npm install -g pnpm
  }
}

# Estas funciones detectan el gestor de paquetes basado en el contexto del proyecto 
# y ejecutan el comando correspondiente, asegurando pnpm si es necesario.
# =============================================================================
runpkg() { local gestor ; gestor=$(detect_package_manager); ensure_pnpm; command "$gestor" "$@"; }
npm()  { local gestor; gestor=$(detect_package_manager); ensure_pnpm; command "$gestor" "$@"; }
pnpm() { local gestor; gestor=$(detect_package_manager); ensure_pnpm; command "$gestor" "$@"; }

# Función que obtiene el estado del repositorio git y lo muestra con colores en el prompt
# =============================================================================
git_prompt_status() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  # 🔵 Detached HEAD
	#-----------------------------------------
  [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null) && \
    { printf "\033[38;5;39m[%s]\033[0m" "$branch"; return; }

  # 🔴 Conflictos
	#-----------------------------------------
  git ls-files -u | grep -q . && { printf "\033[38;5;196m[%s]\033[0m" "$branch"; return; }

  # 🟡 Cambios sin commit
	#-----------------------------------------
  (! git diff --quiet || ! git diff --cached --quiet) && { printf "\033[38;5;220m[%s]\033[0m" "$branch"; return; }

  # 🟢 Repo limpio
	#-----------------------------------------
  printf "\033[38;5;82m[%s]\033[0m" "$branch"
}

# Función que actualiza el cache solo si cambia pwd o 
# git branch, para mejorar rendimiento del prompt
# =============================================================================
update_prompt_cache() {
  [ "$PWD" != "$__LAST_PWD" ] && {
    __LAST_PWD="$PWD"
    local manager
    manager=$(detect_package_manager)
    __PKG_MANAGER=$([ -n "$manager" ] && echo "[$manager]" || echo "")
  }

  __GIT_BRANCH="$(git_prompt_status)"
}

PROMPT_COMMAND=update_prompt_cache

# Diseño del prompt que muestra el gestor de paquetes, el branch de git 
# y el directorio actual, con colores.
# =============================================================================
PS1='\[\033[01;34m\]${__PKG_MANAGER} \[\033[01;32m\]\h: ${__GIT_BRANCH} \[\033[00m\]\w \[\033[01;34m\]\$ \[\033[00m\]'

# NVM_DIR="$HOME/.nvm"
# =============================================================================
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
