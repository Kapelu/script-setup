#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ cerrar-sesion - Script para cerrar la sesión       │
# │ Versión: 2.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 02/02/2026                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail

VERSION="2.0.0"
DELAY=10
BAR_LENGTH=10
MARGIN=5

yellow="\e[0;33m"
green="\e[0;32m"
red="\e[0;31m"
blue="\e[0;34m"
reset="\033[0m"

# funciones de utilidad
# ─────────────────────────────────────────────

command_exists() { command -v "$1" >/dev/null 2>&1; }

cleanup() { echo -ne "\e[?25h"; }
trap cleanup EXIT

cancel() {
    clear
    echo -e "\n${red}❌ Suspensión cancelada${reset}"
    sleep 1
    exit 0
}
trap cancel SIGINT

hide_cursor() { echo -ne "\e[?25l"; }
show_cursor() { echo -ne "\e[?25h"; }


# detección de entorno
# ─────────────────────────────────────────────

detect_session_type() {
    echo "${XDG_SESSION_TYPE:-unknown}"
}

detect_desktop() {
    echo "${XDG_CURRENT_DESKTOP:-unknown}" | tr '[:upper:]' '[:lower:]'
}

detect_terminal() {
    echo "${TERM_PROGRAM:-${COLORTERM:-unknown}}"
}

is_wayland() {
    [[ "$(detect_session_type)" == "wayland" ]]
}

is_x11() {
    [[ "$(detect_session_type)" == "x11" ]]
}

# Barra de progreso
# ─────────────────────────────────────────────

progress_bar() {
    for ((i=1; i<=DELAY; i++)); do
        filled=$i
        empty=$((BAR_LENGTH - filled))

        progress=$(printf '🟩%.0s' $(seq 1 $filled))
        spaces=$(printf '⬜%.0s' $(seq 1 $empty))

        printf "\r%*s%s " "$MARGIN" "" "$progress$spaces"
        sleep 1
    done
    echo ""
}

# Sistema de suspensión
# ─────────────────────────────────────────────

suspend_system() {

    echo -e "${blue}→ Detectando entorno...${reset}"
    DESKTOP=$(detect_desktop)
    SESSION=$(detect_session_type)

    echo -e "${yellow}Desktop:${reset} $DESKTOP"
    echo -e "${yellow}Session:${reset} $SESSION"

    # GNOME (usa DBus si disponible)
    if [[ "$DESKTOP" == *gnome* ]] && command_exists gdbus; then
        echo -e "${green}→ Método GNOME (gdbus)${reset}"
        gdbus call --system \
          --dest org.freedesktop.login1 \
          --object-path /org/freedesktop/login1 \
          --method org.freedesktop.login1.Manager.Suspend true
        return
    fi

    # KDE Plasma
    if [[ "$DESKTOP" == *kde* || "$DESKTOP" == *plasma* ]] && command_exists qdbus; then
        echo -e "${green}→ Método KDE (qdbus)${reset}"
        qdbus org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Suspend true
        return
    fi

    # systemd estándar
    if command_exists systemctl; then
        echo -e "${green}→ Método systemctl${reset}"
        systemctl suspend
        return
    fi

    # loginctl fallback
    if command_exists loginctl; then
        echo -e "${green}→ Método loginctl${reset}"
        loginctl suspend
        return
    fi

    # pm-utils legacy
    if command_exists pm-suspend; then
        echo -e "${green}→ Método pm-suspend${reset}"
        pm-suspend
        return
    fi

    echo -e "${red}❌ No se encontró método compatible.${reset}"
    exit 1
}

# Sistema de cierre de terminal inteligente
# ─────────────────────────────────────────────

close_terminal_if_independent() {

    # Solo si NO estamos en TTY pura
    if [[ -t 0 && -n "${DISPLAY:-}" ]]; then
        # Detectar proceso padre
        PARENT=$(ps -o comm= -p "$PPID" 2>/dev/null || echo "unknown")

        case "$PARENT" in
            gnome-terminal*|konsole*|xfce4-terminal*|tilix*|alacritty*)
                echo -e "${blue}→ Cerrando ventana de terminal${reset}"
                sleep 1
                kill -TERM "$PPID" 2>/dev/null || true
                ;;
        esac
    fi
}

# UI Principal
# ─────────────────────────────────────────────

main() {
    hide_cursor
    clear

    echo -e "💤 ${yellow}El sistema se suspenderá en ${green}$DELAY${reset}${yellow} segundos...${reset}"
    echo ""
    printf "\r%*s%s\n\n" "$MARGIN" "" "Presiona Ctrl+C para cancelar..."

    progress_bar

    echo -e "\n${green}✔ Iniciando suspensión...${reset}"

    suspend_system
    close_terminal_if_independent
}

main "$@"