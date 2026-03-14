#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ Install - Script Post-Install Todo en Uno          │
# │ Versión: 3.2.9                                     │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 04/03/2026                                  │
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
LOG="$HOME/setup-kapelu.log"
green='\e[32m'
reset='\e[0m'

log() {
    echo -e "${green}✅ $1${reset}"
    echo "$1" >> "$LOG"
}

# Detectar distro soportada
detect_distro() {
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
            log "Distribución no soportada: $ID"
            exit 1
        ;;
    esac
}

# Instalar git si no existe
check_git() {
    if ! command -v git >/dev/null; then
        log "Instalando git"
        sudo apt update
        sudo apt install -y git
    fi
}

# Dar permisos a scripts con shebang
permits() {
    while IFS= read -r -d '' file; do
        if head -n1 "$file" | grep -q "^#!"; then
            chmod +x "$file"
        fi
    done < <(find . -type f -print0)
}

backup_bashrc() {
    if [ -f "$HOME_DIR/.bashrc" ]; then
        cp "$HOME_DIR/.bashrc" "$HOME_DIR/.bashrc.backup.$(date +%s)"
        log "Backup de .bashrc creado"
    fi
}

# Clonar repo temporal
clone_repo() {
    log "Clonando repositorio"
    git clone -b main "$REPO" "$TMP_DIR"
}

# Copiar scripts al home
copy_scripts() {
    mkdir -p "$HOME_DIR/script"
    cp -r "$TMP_DIR/script/." "$HOME_DIR/script/"
    find "$HOME_DIR/script" -type f -name "*.sh" -exec chmod +x {} \;
}

# Copiar configs
copy_config() {
    cp "$TMP_DIR/config/.bashrc" "$HOME_DIR/.bashrc"
    cp "$TMP_DIR/config/protect-main.json" "$HOME_DIR/"
}

# Crear accesos directos en el escritorio
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

    killall -q nautilus 2>/dev/null
}

system_update() { sudo apt update -y; sudo apt upgrade -y; sudo apt full-upgrade -y; }
system_cleanup() { sudo apt autoremove -y; sudo apt clean; }

# Ejecutar setup.sh final
run_setup() {
    printf "${green}📦 ¿Desea ejecutar setup.sh? (s/n): ${reset}"
    read RESP

    if [ "$RESP" = "s" ]; then
        FILE="$HOME_DIR/script/setup.sh"

        if [ ! -f "$FILE" ]; then
            echo "❌ Error: setup.sh no encontrado en $HOME_DIR/script/"
            return 1
        fi

        if [ ! -x "$FILE" ]; then
            chmod +x "$FILE"
        fi

        "$FILE"
    else
        system_update
        system_cleanup
    fi
}

cleanup() { rm -rf "$TMP_DIR"; }

main() {
    log "Iniciando Secuencia Post-Install setup-kapelu"

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