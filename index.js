#!/usr/bin/env node

const { execSync } = require("child_process");
const pkg = require("./package.json");
const { clear } = require("console");

function exists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function installNode() {
  console.log("📦 Instalando Node.js y npm...\n");
  execSync("sudo apt update", { stdio: "inherit" });
  execSync("sudo apt install -y nodejs npm", { stdio: "inherit" });
}

function latestVersion() {
  try {
    return execSync(`npm view ${pkg.name} version`, {
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim();
  } catch {
    return null;
  }
}

function updateIfNeeded() {
  const current = pkg.version;
  const latest = latestVersion();
  if (!latest) return;

  if (current !== latest) {
    console.log(`⬆ Nueva versión disponible ${latest} (actual ${current})`);
    console.log("Actualizando kapelu...\n");
    execSync(`npm install -g ${pkg.name}`, { stdio: "inherit" });
    process.exit(0);
  }
}

function autoUpdateGitHub() {
  // Si el script existe, hacer pull del repo para tener versión más reciente
  try {
    execSync(
      `if [ -d "/tmp/script-setup" ]; then cd /tmp/script-setup && git pull --rebase; fi`,
      { stdio: "inherit", shell: "/bin/bash" },
    );
  } catch {}
}

try {
  console.log("🔎 Verificando Node.js y npm...");
  if (!exists("node") || !exists("npm")) installNode();
  console.log("✔ Node.js y npm OK\n");

  console.log("🔎 Verificando actualizaciones en npm...");
  updateIfNeeded();

  console.log("🔎 Actualizando desde GitHub si existe repo local...");
  autoUpdateGitHub();

  console.log("🚀 Ejecutando install.sh\n");
  execSync(`bash ${__dirname}/install.sh`, { stdio: "inherit" });
} catch (err) {
  clear
  console.log("");
  console.error("          \n❌ Error ejecutando Post-Install:", err.message);
  console.log("");
  console.log("");

  process.exit(1);
}