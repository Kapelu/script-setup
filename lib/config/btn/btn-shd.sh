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
blue="\e[0;34m"
reset="\033[0m"

# utilidades
# ─────────────────────────────────────────────
command_exists() { command -v "$1" >/dev/null 2>&1;}

cleanup() { echo -ne "\e[?25h"; }
trap cleanup EXIT

cancel() {
    clear
    echo -e "\n${red}❌ Apagado cancelado${reset}"
    sleep 1
    exit 0
}
trap cancel SIGINT

hide_cursor() { echo -ne "\e[?25l"; }
show_cursor() { echo -ne "\e[?25h"; }

# Barra de progreso
# ─────────────────────────────────────────────
progress_bar() {

    for ((i=1;i<=DELAY;i++)); do
        filled=$i
        empty=$((BAR_LENGTH - filled))

        progress=$(printf '🟩%.0s' $(seq 1 $filled))
        spaces=$(printf '⬜%.0s' $(seq 1 $empty))

        printf "\r%*s%s " "$MARGIN" "" "$progress$spaces"

        sleep 1
    done

    echo ""
}

# detección de entorno
# ─────────────────────────────────────────────
detect_session_type() {
    echo "${XDG_SESSION_TYPE:-unknown}"
}

detect_desktop() {
    echo "${XDG_CURRENT_DESKTOP:-unknown}" | tr '[:upper:]' '[:lower:]'
}

# sistema de apagado
# ─────────────────────────────────────────────
shutdown_system() {

    echo -e "${blue}→ Detectando entorno...${reset}"

    DESKTOP=$(detect_desktop)
    SESSION=$(detect_session_type)

    echo -e "${yellow}Desktop:${reset} $DESKTOP"
    echo -e "${yellow}Session:${reset} $SESSION"

    # GNOME (DBus)
    if [[ "$DESKTOP" == *gnome* ]] && command_exists gdbus; then

        echo -e "${green}→ Método GNOME (gdbus)${reset}"

        gdbus call --system \
          --dest org.freedesktop.login1 \
          --object-path /org/freedesktop/login1 \
          --method org.freedesktop.login1.Manager.PowerOff true

        return
    fi

    # KDE
    if [[ "$DESKTOP" == *kde* || "$DESKTOP" == *plasma* ]] && command_exists qdbus; then

        echo -e "${green}→ Método KDE (qdbus)${reset}"

        qdbus org.freedesktop.login1 \
          /org/freedesktop/login1 \
          org.freedesktop.login1.Manager.PowerOff true

        return
    fi

    # systemd estándar
    if command_exists systemctl; then
        echo -e "${green}→ Método systemctl${reset}"
        systemctl poweroff
        return
    fi

    # loginctl
    if command_exists loginctl; then
        echo -e "${green}→ Método loginctl${reset}"
        loginctl poweroff
        return
    fi

    # shutdown clásico
    if command_exists shutdown; then
        echo -e "${green}→ Método shutdown${reset}"
        shutdown -h now
        return
    fi

    echo -e "${red}❌ No se encontró método compatible.${reset}"
    exit 1
}

# cierre inteligente de terminal
# ─────────────────────────────────────────────
close_terminal_if_independent() {

    if [[ -t 0 && -n "${DISPLAY:-}" ]]; then

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

# UI principal
# ─────────────────────────────────────────────
main() {

    hide_cursor
    clear

    echo -e "⏻ ${yellow}El sistema se apagará en ${green}$DELAY${reset}${yellow} segundos...${reset}"
    echo ""

    printf "\r%*s%s\n\n" "$MARGIN" "" "Presiona Ctrl+C para cancelar..."

    progress_bar

    echo -e "\n${green}✔ Iniciando apagado...${reset}"

    shutdown_system

    close_terminal_if_independent
}

main "$@"