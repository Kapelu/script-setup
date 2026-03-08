#!/usr/bin/env node

const { execSync } = require("child_process");

execSync("bash install.sh", { stdio: "inherit" });
