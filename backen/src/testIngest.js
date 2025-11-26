// src/testIngest.js
require("dotenv").config();
const { ingestUrls } = require("./services/ingest");

async function main() {
  const urls = [
    "https://example.com", // cámbialas por las URLs reales que quieras ingestar
    // "https://otra-url.com",
  ];

  console.log("[testIngest] Empezando ingesta de URLs:", urls);

  const results = await ingestUrls(urls);

  console.log("\n[testIngest] Resultados:");
  console.log(JSON.stringify(results, null, 2));
}

main().catch((err) => {
  console.error("[testIngest] Error general:", err.message);
});