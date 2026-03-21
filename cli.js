#!/usr/bin/env node

const { execSync } = require("child_process");
const path = require("path");

// Obtiene la ruta absoluta del script install.sh en la misma carpeta
const installScript = path.join(__dirname, "install.sh");

try {
  // Ejecuta bash pasando la ruta del script
  // stdio: 'inherit' hace que veas la salida en tu terminal tal cual
  execSync(`bash "${installScript}"`, {
    stdio: "inherit",
    shell: "/bin/bash",
  });
} catch (error) {
  // Si algo falla, muestra el error básico y sale
  console.error("Error al ejecutar install.sh:", error.message);
  process.exit(1);
}
