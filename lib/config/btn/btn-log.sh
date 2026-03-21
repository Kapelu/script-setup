#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ cerrar-sesion - Script para cerrar la sesión       │
# │ Versión: 2.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 04/03/2026                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail

DELAY=10
BAR_LENGTH=10
MARGIN=5

yellow="\e[0;33m"
green="\e[0;32m"
red="\e[0;31m"
reset="\033[0m"

# Funciones de utilidad
# ─────────────────────────────────────────────

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

cleanup() {
    echo -ne "\e[?25h"
}
trap cleanup EXIT

cancel() {
    clear
    echo -e "\n${red}❌ Operación cancelada${reset}"
    sleep 1
    exit 0
}
trap cancel SIGINT

# UI Principal
# ─────────────────────────────────────────────

echo -ne "\e[?25l"
clear
echo -e "💤 ${yellow}La sesión se cerrará en ${green}$DELAY${reset}${yellow} segundos...${reset}"
echo ""
printf "\r%*s%s\n\n" "$MARGIN" "" "Presiona Ctrl+C para cancelar..."

# Barra de progreso
# ─────────────────────────────────────────────

for ((i=1; i<=DELAY; i++)); do
    filled=$i
    empty=$((BAR_LENGTH - filled))

    progress=$(printf '🟩%.0s' $(seq 1 $filled))
    spaces=$(printf '⬜%.0s' $(seq 1 $empty))

    printf "\r%*s%s " "$MARGIN" "" "$progress$spaces" # inicio =%d/%d fin="$i" "$DELAY"
    sleep 1
done

echo -e "\n\n${green}✔ Cerrando sesión...${reset}"

# Detección de entorno y cierre de sesión
# ─────────────────────────────────────────────

SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
DESKTOP="${XDG_CURRENT_DESKTOP:-unknown}"

echo -e "${yellow}→ Entorno detectado:${reset} $DESKTOP ($SESSION_TYPE)"

# 1- GNOME (método preferido)
if command_exists gnome-session-quit; then
    echo -e "${green}→ Usando gnome-session-quit${reset}"
    gnome-session-quit --logout --no-prompt
    exit 0
fi

# 2- loginctl con sesión activa
if command_exists loginctl; then
    SESSION_ID=$(loginctl list-sessions --no-legend 2>/dev/null | awk -v user="$USER" '$2==user {print $1; exit}')

    if [[ -n "${SESSION_ID:-}" ]]; then
        echo -e "${green}→ Usando loginctl terminate-session${reset}"
        loginctl terminate-session "$SESSION_ID"
        exit 0
    fi

    echo -e "${green}→ Usando loginctl terminate-user${reset}"
    loginctl terminate-user "$USER"
    exit 0
fi

# 3- Fallback agresivo
echo -e "${red}→ Fallback: matando procesos del usuario${reset}"
pkill -KILL -u "$USER"