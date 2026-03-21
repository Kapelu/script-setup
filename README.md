<div align="center">
<h1 style='margin: 0 0 2rem; font-size: 2.5rem;'>🔧 setup-kapelu</h1 >
</div>
<div align="center">

[![npm version](https://img.shields.io/npm/v/setup-kapelu.svg)](https://www.npmjs.com/package/kpsetup)
![Bash](https://img.shields.io/badge/Bash-4%2B-blue)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-orange)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/version-3.0-informational)

> 🐧 Ubuntu/Debian/Linux Mint/Pop!_OS | 🚀 One-command setup
</div>

<div align="center">

## Descripción general

`script-setup` es una colección de utilidades de terminal ***post-install*** orientadas al rendimiento, diseñadas para mejorar la productividad de los desarrolladores en sistemas Ubuntu. El proyecto prioriza la baja sobrecarga, la arquitectura modular de Bash y un comportamiento de ejecución predecible.

---
## ⚡ Instalación Rápida
</div>


```bash
# Instalar globalmente vía npm
```
```
setup-kapelu/
├── bin/
│   └── setup-kapelu          # Script principal ejecutable
├── lib/
│   ├── config/
│   │   ├── .bashrc           # Configuración bash personalizada
│   │   └── protect-main.json # Archivo de configuración de `main` en Github
│   └── scripts/
│       ├── btn-log.sh        # Script: cerrar sesión
│       ├── btn-shd.sh        # Script: apagar
│       ├── btn-sus.sh        # Script: suspender
│       └── node-clean.sh     # Script: limpieza node_modules
├── src/
│   └── setup-kapelu.sh       # Fuente con documentación completa
├── package.json
├── README.md
└── LICENSE
```
<div align="center">

## 📦 Modulos

</div>

### ***🧹 node-clean***

Herramienta CLI interactiva para localizar y eliminar `node_modules` y `.next` dentro de un árbol de directorios. Se pueden agregar más carpetas o archivos.

simplemente modificar la variable
```bash
TARGETS=("node_modules" ".next")()
```
### <u>Características:</u>
- Interfaz TUI basada en `dialog`
- Cálculo previo de espacio a liberar
- Borrado total o selectivo
- Soporte modo `--dry-run`
- Restauración segura del estado de la terminal

### <u>Uso</u>:
```bash
  node-clean [--dry-run]
```

------------------------------------------------------------------------
### ***⚙️ Motor de prompts de Bash optimizado (.bashrc)***

El archivo implementa un prompt dinámico optimizado con cacheo inteligente, orientado a entornos de desarrollo Node/Next.js.

### <u>Características:</u>

- Crea una carpeta llamada script donde se instalaran los script personalizables y ejecutables
- Cache global
- Busqueda de `package.json`
- Detección inteligente del `package manager`
- Detección inteligente de `git status`

      🟢 → repo limpio
      🟡 → cambios sin commit
      🔴 → conflictos
      🔵 → detached HEAD
- Prompt contextual con heurística de proyecto

</br>
<div align="center">
<p style='margin: 0 0 2rem; font-size: 1.5rem;'>📈 Comparación con <strong>.bashrc</strong> estándar de Ubuntu vs Prompt v2.0</p >
</div>

<div align="center">

| Característica             |Ubuntu default|Versión 3.0|
|----------------------------|--------------|-----------|
| Prompt dinámico            | ❌           | ✔️        |
| Rama Git                   | ❌           | ✔️        |
| Detectar Node project      | ❌           | ✔️        |
| Detectar package manager   | ❌           | ✔️        |
| Cache de estado            | ❌           | ✔️        |
| Optimización por PWD       | ❌           | ✔️        |


#### Está más cerca de un mini framework de prompt que de un `.bashrc` común‼️
</div>

------------------------------------------------------------------------

### ***🛡️ protect-main.json***

Es un archivo `.json` que protege el main branch de un repositorio git, evitando pushes accidentales de terceroas.

### <u>Características:</u>

- `Estado de ejecución` Activo
- `Lista de omisión` Repository admin
- `Criterio de selección de rama` Default
- `Restrict updates` Permitir que solo los usuarios con permisos de omisión actualicen las referencias coincidentes.
- `Restrict deletions` Permitir que solo los usuarios con permisos de omisión eliminen referencias coincidentes.
- `Require linear history` Evita que las confirmaciones de fusión se envíen a referencias coincidentes.
- `Require a pull request before merging` Requerir que todas las confirmaciones se realicen en una rama distinta a la de destino y se envíen mediante una solicitud de extracción antes de que se puedan fusionar.
- `Require conversation resolution before merging` Todas las conversaciones sobre el código deben resolverse antes de que se pueda fusionar una solicitud de extracción.
- `Block force pushes` Evita que los usuarios con acceso de envío fuercen el envío a los árbitros.

### <u>Uso</u>:

Luego en el repositorio de `github` ir a `Settings` → `Branches` → `Add rule` → `Import` → `Upload JSON` y agregar → ***protect-main.json*** .

------------------------------------------------------------------------