// src/testIngest.js
require("dotenv").config();
const { ingestUrls } = require("./services/ingest");

async function main() {
  const urls = [
    "https://programasparaelbienestar.gob.mx/",
    "https://www.gob.mx/becasbenitojuarez",
  ];

  console.log("[testIngest] Empezando ingesta de URLs:", urls);

  const results = await ingestUrls(urls);

  console.log("\n[testIngest] Resultados:");
  console.log(JSON.stringify(results, null, 2));
}

main().catch((err) => {
  console.error("[testIngest] Error general:", err.message);
});