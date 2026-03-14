#!/usr/bin/env node

const { execSync } = require("child_process");
const { existsSync } = require("fs");
const pkg = require("./package.json");

function run(cmd, options = {}) {
  execSync(cmd, { stdio: "inherit", shell: "/bin/bash", ...options });
}

function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function ensureNode() {
  if (!commandExists("node") || !commandExists("npm")) {
    console.log("📦 Node.js y npm no detectados. Instalando...");
    run(
      "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash",
    );
    run(
      'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"',
    );
    run("nvm install --lts && nvm use --lts");
    run("npm install -g pnpm yarn");
  } else {
    console.log("✔ Node.js y npm OK");
  }
}

function updateKapelu() {
  const latest = execSync(`npm view ${pkg.name} version`, {
    stdio: ["ignore", "pipe", "ignore"],
  })
    .toString()
    .trim();
  if (pkg.version !== latest) {
    console.log(`⬆ Nueva versión disponible: ${latest}. Actualizando...`);
    run(`npm install -g ${pkg.name}`);
    process.exit(0);
  }
}

try {
  console.log("🔎 Verificando Node/npm...");
  ensureNode();

  console.log("🔎 Verificando actualizaciones...");
  updateKapelu();

  console.log("🚀 Ejecutando instalador completo...");
  run(`bash ${__dirname}/install.sh`);
} catch (err) {
  console.clear();
  console.error("\n❌ Error ejecutando setup-kapelu\n");
  if (err.status) console.error("Código de salida:", err.status);
  if (err.cmd) console.error("Comando:", err.cmd);
  if (err.stderr) console.error(err.stderr.toString());
  console.error(err.message);
  process.exit(1);
}
