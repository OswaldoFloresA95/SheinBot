// src/services/ingest.js
const db = require("../db");
const { scrapeUrl } = require("./scraper");
const { splitIntoChunks } = require("./chunker");
const { getEmbedding } = require("./embeddings");

/**
 * Convierte un array de números JS en un literal de vector
 * que pgvector entiende: [0.1, 0.2] -> "[0.1,0.2]"
 */
function toVectorLiteral(array) {
  if (!Array.isArray(array) || array.length === 0) {
    throw new Error("Embedding vacío o inválido");
  }
  return `[${array.join(",")}]`;
}

/**
 * Ingresa UNA sola URL:
 * - hace scraping
 * - inserta en documents
 * - parte en chunks
 * - genera embeddings
 * - inserta en chunks
 */
async function ingestUrl(url) {
  console.log(`\n[ingest] Iniciando ingesta de: ${url}`);

  // 1) Scraping
  const { title, content } = await scrapeUrl(url);
  console.log(`[ingest] Título: ${title || "(sin título)"}`);

  // 2) Insertar documento
  const docResult = await db.query(
    `
    INSERT INTO public.documents (url, title, raw_content)
    VALUES ($1, $2, $3)
    RETURNING id;
  `,
    [url, title, content]
  );

  const documentId = docResult.rows[0].id;
  console.log(`[ingest] Documento creado con id: ${documentId}`);

  // 3) Partir en chunks
  const chunks = splitIntoChunks(content, 1000); // puedes ajustar tamaño
  console.log(`[ingest] Total de chunks generados: ${chunks.length}`);

  // 4) Insertar chunks con embeddings
  let position = 0;

  for (const chunkText of chunks) {
    try {
      const embeddingArray = await getEmbedding(chunkText);
      const embeddingLiteral = toVectorLiteral(embeddingArray);

      await db.query(
        `
        INSERT INTO public.chunks (document_id, content, embedding, position)
        VALUES ($1, $2, $3::vector, $4);
      `,
        [documentId, chunkText, embeddingLiteral, position]
      );

      position++;
    } catch (err) {
      console.error(
        `[ingest] Error al procesar chunk en posición ${position}:`,
        err.message
      );
    }
  }

  console.log(
    `[ingest] Ingesta completa para ${url} (documento ${documentId}, chunks: ${position})`
  );

  return { documentId, chunksInserted: position };
}

/**
 * Ingresa varias URLs en serie.
 *
 * @param {string[]} urls
 */
async function ingestUrls(urls) {
  const results = [];

  for (const url of urls) {
    try {
      const result = await ingestUrl(url);
      results.push({ url, ...result, ok: true });
    } catch (err) {
      console.error(`[ingest] Error procesando URL ${url}:`, err.message);
      results.push({ url, ok: false, error: err.message });
    }
  }

  return results;
}

module.exports = {
  ingestUrl,
  ingestUrls,
};