#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ cerrar-sesion - Script para cerrar la sesión       │
# │ Versión: 2.0                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 16/03/2024                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝

set -euo pipefail

TARGETS=("node_modules" ".next")
NODE_DIRS=()
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

declare -A DIR_SIZES

cleanup() {
    tput rmcup 2>/dev/null || true
    clear
}

salir() {
    cleanup
    echo ""
    echo "Gracias por usar node-clean by Kapelu."
    echo "https://github.com/Kapelu"
    echo "¡Hasta la próxima!"
    echo ""
    exit 0
}

trap salir EXIT INT TERM

validar_dialog() {
    if command -v dialog >/dev/null 2>&1; then
        return 0
    fi

    echo "⚠️  'dialog' no está instalado. Iniciando proceso de instalación..."

    # Detectar Sistema Operativo
    OS="$(uname -s)"

    case "$OS" in
        Darwin)
            # macOS
            echo "🍎 Detectado macOS..."
            
            # Verificar si Homebrew está instalado
            if ! command -v brew >/dev/null 2>&1; then
                echo "🍺 Homebrew no encontrado. Instalando Homebrew..."
                
                # Instalar Homebrew automáticamente (script oficial no interactivo)
                # Usamos NONINTERACTIVE=1 para evitar prompts durante la instalación de brew
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Verificar si la instalación de brew fue exitosa
                if ! command -v brew >/dev/null 2>&1; then
                    echo "❌ Error crítico: No se pudo instalar Homebrew."
                    echo "   Por favor, instálalo manualmente visitando: https://brew.sh"
                    exit 1
                fi
                
                # Agregar brew al PATH si es necesario (común en instalaciones nuevas en Apple Silicon)
                # Esto asegura que el comando 'brew' funcione inmediatamente en este script
                if [[ -f /opt/homebrew/bin/brew ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -f /usr/local/bin/brew ]]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                
                echo "✅ Homebrew instalado correctamente."
            else
                echo "🍺 Homebrew ya está instalado."
            fi

            # Proceder a instalar dialog con brew
            echo "📦 Instalando 'dialog' vía Homebrew..."
            brew install dialog
            
            ;;
        Linux)
            # Linux
            echo "🐧 Detectado Linux..."
            if command -v apt >/dev/null 2>&1; then
                sudo apt update && sudo apt install -y dialog
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y dialog
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y dialog
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -Sy --noconfirm dialog
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y dialog
            else
                echo "❌ No se pudo determinar el gestor de paquetes de Linux."
                echo "   Por favor instala 'dialog' manualmente."
                exit 1
            fi
            ;;
        *)
            echo "❌ Sistema operativo no soportado: $OS"
            echo "   Este script requiere Bash y dialog en un sistema Unix-like (Linux/macOS)."
            exit 1
            ;;
    esac

    # Verificación final
    if ! command -v dialog >/dev/null 2>&1; then
        echo "❌ Falló la instalación de 'dialog'."
        exit 1
    fi
    
    echo "✅ 'dialog' instalado y listo para usar."
}

relative_path() {
    echo "${1#$BASE_DIR/}"
}

get_size_mb() {
    echo "${DIR_SIZES[$1]:-0}"
}

calc_height() {

    local items=$1
    local max_height=$((TERM_HEIGHT - 8))

    if [[ $items -lt $max_height ]]; then
        echo $((items + 8))
    else
        echo "$max_height"
    fi
}

calc_all_sizes() {

    local results

    results=$(du -sm "${NODE_DIRS[@]}" 2>/dev/null)

    while read -r size path; do
        DIR_SIZES["$path"]=$size
    done <<< "$results"
}

scan_with_progress() {

    local TMP
    TMP=$(mktemp)

    (
        find "$BASE_DIR" -type d \( -name node_modules -o -name .next \) -prune 2>/dev/null > "$TMP"
    ) &

    local PID=$!
    local progress=0

    while kill -0 "$PID" 2>/dev/null; do
        progress=$(( (progress + 2) % 100 ))
        echo $progress
        sleep 0.1
    done | dialog --gauge "Escaneando proyectos Node..." 10 70 0

    mapfile -t NODE_DIRS < "$TMP"

    rm -f "$TMP"
}

confirmar_borrado() {

    local DIRS=("$@")
    local TOTAL_MB=0
    local SIZE_MB

    for DIR in "${DIRS[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        TOTAL_MB=$((TOTAL_MB + SIZE_MB))
    done

    dialog --title "Confirmación de borrado" \
        --yes-label "Sí" --no-label "No" \
        --yesno "Se van a eliminar ${#DIRS[@]} carpetas.\nEspacio total a liberar: ${TOTAL_MB} MB\n\n¿Desea continuar?" \
        10 $((TERM_WIDTH / 2))

    [[ $? -eq 0 ]]
}

mostrar_carpetas() {

    local DIR_LIST=""
    local TOTAL_MB=0
    local SIZE_MB
    local REL

    for DIR in "${NODE_DIRS[@]}"; do

        SIZE_MB=$(get_size_mb "$DIR")
        REL=$(relative_path "$DIR")

        DIR_LIST+="$REL → ${SIZE_MB} MB\n"

        TOTAL_MB=$((TOTAL_MB + SIZE_MB))

    done

    local HEIGHT
    HEIGHT=$(calc_height "${#NODE_DIRS[@]}")

    dialog --title "Carpetas encontradas" \
        --msgbox "Se encontraron ${#NODE_DIRS[@]} carpetas:\n\n$DIR_LIST\nTamaño total combinado: ${TOTAL_MB} MB" \
        "$HEIGHT" "$TERM_WIDTH"
}

borrar_todas() {

    local TOTAL_DELETED_MB=0
    local SIZE_MB
    local REL

    if $DRY_RUN; then

        local DIR_LIST=""

        for DIR in "${NODE_DIRS[@]}"; do
            REL=$(relative_path "$DIR")
            DIR_LIST+="$REL\n"
        done

        dialog --msgbox "== DRY-RUN ==\n\n$DIR_LIST" \
            "$(calc_height "${#NODE_DIRS[@]}")" "$TERM_WIDTH"

        return
    fi

    confirmar_borrado "${NODE_DIRS[@]}" || return

    for DIR in "${NODE_DIRS[@]}"; do

        SIZE_MB=$(get_size_mb "$DIR")

        [[ -d "$DIR" ]] && rm -rf -- "$DIR"

        TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))

    done

    dialog --msgbox "Se eliminaron todas las carpetas.\nEspacio liberado: ${TOTAL_DELETED_MB} MB" \
        10 $((TERM_WIDTH / 2))
}

borrar_checklist() {

    local CHECKLIST_ARGS=()
    local MAP_DIRS=()
    local TOTAL_DELETED_MB=0
    local SIZE_MB
    local REL

    for DIR in "${NODE_DIRS[@]}"; do

        SIZE_MB=$(get_size_mb "$DIR")
        REL=$(relative_path "$DIR")

        local LABEL="item$(( ${#MAP_DIRS[@]} + 1 ))"

        MAP_DIRS+=("$DIR")

        CHECKLIST_ARGS+=("$LABEL" "$REL → ${SIZE_MB} MB" "off")

    done

    local HEIGHT
    HEIGHT=$(calc_height "${#NODE_DIRS[@]}")

    local SELECTED

    SELECTED=$(dialog \
        --title "Seleccionar carpetas a borrar" \
        --checklist "Use espacio para seleccionar:" \
        "$HEIGHT" "$TERM_WIDTH" 20 \
        "${CHECKLIST_ARGS[@]}" \
        3>&1 1>&2 2>&3) || return

    [[ -z "$SELECTED" ]] && return

    local TO_DELETE=()

    for LABEL in $SELECTED; do

        LABEL=${LABEL//\"/}

        local INDEX=$(( ${LABEL//[!0-9]/} - 1 ))

        TO_DELETE+=("${MAP_DIRS[$INDEX]}")

    done

    confirmar_borrado "${TO_DELETE[@]}" || return

    for DIR in "${TO_DELETE[@]}"; do

        SIZE_MB=$(get_size_mb "$DIR")

        [[ -d "$DIR" ]] && rm -rf -- "$DIR"

        TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))

    done

    dialog --msgbox "Proceso completado.\nEspacio liberado: ${TOTAL_DELETED_MB} MB" \
        10 $((TERM_WIDTH / 2))
}

# MAIN

validar_dialog

tput smcup
clear
printf '\033[3J'

TERM_WIDTH=$(tput cols)
TERM_HEIGHT=$(tput lines)

while true; do

    ROOT_DIR_NAME=$(dialog \
        --title "Seleccionar carpeta raíz" \
        --inputbox "Ingrese la carpeta donde buscar:" \
        10 $((TERM_WIDTH / 2)) \
        3>&1 1>&2 2>&3)

    STATUS=$?

    [[ $STATUS -ne 0 ]] && salir

    if [[ -z "$ROOT_DIR_NAME" ]]; then
        dialog --msgbox "No ingresó ningún nombre de carpeta." 6 $((TERM_WIDTH / 2))
        continue
    fi

    BASE_DIR="$HOME/$ROOT_DIR_NAME"

    [[ -d "$BASE_DIR" ]] && break

    dialog --msgbox "La carpeta $BASE_DIR no existe." 6 $((TERM_WIDTH / 2))

done

scan_with_progress

[[ ${#NODE_DIRS[@]} -eq 0 ]] && {

    dialog --msgbox "No se encontraron carpetas: ${TARGETS[*]}" \
        8 $((TERM_WIDTH / 2))

    salir
}

calc_all_sizes

mostrar_carpetas

while true; do

    OPCION=$(dialog \
        --title "Opciones de borrado" \
        --menu "Seleccione una opción:" \
        12 50 3 \
        1 "Borrar todas" \
        2 "Borrado múltiple" \
        3 "Salir" \
        3>&1 1>&2 2>&3) || salir

    case $OPCION in
        1) borrar_todas ;;
        2) borrar_checklist ;;
        3) salir ;;
        *) dialog --msgbox "Opción inválida" 5 30 ;;
    esac

done