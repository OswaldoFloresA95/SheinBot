// src/services/search.js
const db = require("../db/index"); // Aseguramos la ruta explícita por si acaso

/**
 * Convierte un array de números JS en un literal de vector para Postgres/pgvector:
 * [0.1, 0.2, 0.3] -> "[0.1,0.2,0.3]"
 */
function toVectorLiteral(array) {
  if (!Array.isArray(array) || array.length === 0) {
    throw new Error("Embedding vacío o inválido");
  }
  return `[${array.join(",")}]`;
}

/**
 * Busca los chunks más relevantes dado el embedding de una pregunta.
 *
 * @param {number[]} questionEmbedding - Array de floats.
 * @param {number} limit
 */
async function searchRelevantChunks(questionEmbedding, limit = 5) {
  if (!Array.isArray(questionEmbedding) || questionEmbedding.length === 0) {
    throw new Error("Embedding de pregunta inválido para búsqueda");
  }

  // Convertimos el array JS a literal de vector para pgvector
  const embeddingLiteral = toVectorLiteral(questionEmbedding);

  // ⭐ CAMBIO: Usamos <=> (Distancia Coseno) en lugar de <-> (Euclidiana)
  // Esto mejora la precisión semántica para respuestas de IA.
  const sql = `
    SELECT 
      id, 
      document_id, 
      content, 
      (embedding <=> $1::vector) AS distance
    FROM public.chunks
    ORDER BY distance ASC
    LIMIT $2;
  `;

  const params = [embeddingLiteral, limit];

  const result = await db.query(sql, params);
  return result.rows;
}

module.exports = {
  searchRelevantChunks,
};