<div align="center">
<h1 style='margin: 0 0 2rem; font-size: 2.5rem;'>kpsetup</h1 >
</div>
<div align="center">

![Bash](https://img.shields.io/badge/Bash-4%2B-blue)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-orange)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/version-3.0-informational)

> 🐧 Ubuntu_OS | 🚀 One-command setup
</div>

<div align="center">

## Descripción general
<div align="justify">

`kpsetup` no es solo un script de instalación: está diseñado como un sistema reproducible, mantenible y robusto para levantar entornos completos de forma consistente.

Es una colección de utilidades de terminal ***post-install*** orientadas al rendimiento, diseñadas para mejorar la productividad de los desarrolladores en sistemas Ubuntu. El proyecto prioriza la baja sobrecarga, la arquitectura modular de Bash y un comportamiento de ejecución predecible.
<div align="center">

## Características
</div>

✅ Instalación automatizada de dependencias

✅ Separación de ejecución (root / usuario)

✅ Funciones idempotentes

✅ Sistema de logging estructurado

✅ Validación de comandos instalados

✅ Manejo de errores centralizado

✅ Permite ser fácilmente modficado en cuanto a preferencias de instalación
<div align="center">

## ⚡ Instalación Rápida

</div>


1. ***Copiar el archivo kpsetup o descargarlo***

2. ***Crear archivo como kpsetup o el nombre que elijan.***

3. ***Dar permisos***
    ```bash
    chmod +x kpsetup
    ```
4. ***Ejecutar***
    ```bash  
    ./kpsetup
    ``` 
<div align="center">

## ♻️ Idempotencia
</div>

Las funciones están diseñadas para poder ejecutarse múltiples veces sin efectos secundarios.
Ejemplo:
* No reinstala paquetes si ya existen
* No rompe configuraciones previas
<div align="center">

## ⚙️ Modificaciones
<div align="justify">

Las funciones están diseñadas para poder modificarlas en cuanto a gusto de programas a instalar, siempre teniendo en cuenta el uso de las funciones propias del script.
<div align="center">

## ⚠️ PREPARANDO FUNCIONES NUEVA Y MODIFICACIONES ‼️
</div>

