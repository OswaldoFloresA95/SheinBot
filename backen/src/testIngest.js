// src/testIngest.js
require("dotenv").config();
const { ingestUrls } = require("./services/ingest");

async function main() {
  const urls = [
    "https://www.gob.mx/presidencia/articulos/version-estenografica-conferencia-de-prensa-de-la-presidenta-claudia-sheinbaum-pardo-del-4-de-abril-de-2025",
    "https://www.gob.mx/presidencia/articulos/version-estenografica-conferencia-de-prensa-de-la-presidenta-claudia-sheinbaum-pardo-del-9-de-abril-de-2025",
    "https://www.dof.gob.mx/nota_detalle.php?codigo=5758077&fecha=22/05/2025#gsc.tab=0",
    "https://www.dof.gob.mx/nota_detalle.php?codigo=5758079&fecha=22/05/2025#gsc.tab=0",
    "https://www.gob.mx/presidencia/prensa/plan-mexico-presidenta-claudia-sheinbaum-pone-en-marcha-los-primeros-15-polos-de-desarrollo-economico-para-el-bienestar-en-14-estados",
    "https://www.gob.mx/presidencia/prensa/presidenta-firma-acuerdo-con-22-grupos-empresariales-para-aumentar-los-productos-hechos-en-mexico-en-tiendas?idiom=es",
    "https://www.gob.mx/presidencia/prensa/plan-mexico-presidenta-claudia-sheinbaum-anuncia-decreto-para-convertir-al-pais-en-lider-de-la-industria-farmaceutica",
    "https://www.gob.mx/shcp/prensa/comunicado-no-19-suscriben-acuerdo-el-gobierno-federal-banco-de-mexico-y-la-abm-para-incrementar-el-financiamiento-a-las-pymes?idiom=es-MX",
    "https://www.gob.mx/presidencia/prensa/se-ofertaran-100-mil-empleos-adicionales-como-parte-del-plan-mexico-presidenta-claudia-sheinbaum?idiom=es",

    

  ];

  console.log("[testIngest] Empezando ingesta de URLs:", urls);

  const results = await ingestUrls(urls);

  console.log("\n[testIngest] Resultados:");
  console.log(JSON.stringify(results, null, 2));
}

main().catch((err) => {
  console.error("[testIngest] Error general:", err.message);
});