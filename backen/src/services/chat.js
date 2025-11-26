// src/services/chat.js

const { getEmbedding } = require("./embeddings");
const { searchRelevantChunks } = require("./search");
const { askLLM } = require("./llm");

/**
 * Orquesta el flujo RAG:
 * 1. Embedding de la pregunta.
 * 2. Búsqueda de chunks relevantes en la BD.
 * 3. Llamada al LLM con esos contextos.
 *
 * @param {string} question - Pregunta del usuario.
 * @param {object} options - Opciones opcionales.
 * @param {number} options.topK - Cuántos chunks usar como contexto.
 * @returns {Promise<{ answer: string, contexts: { id, document_id, content, score }[] }>}
 */
async function answerQuestionWithRAG(question, options = {}) {
  const topK = options.topK || 5;

  if (!question || !question.trim()) {
    throw new Error("Pregunta vacía");
  }

  // 1) Embedding de la pregunta
  const questionEmbedding = await getEmbedding(question);

  // 2) Búsqueda de chunks relevantes
  const chunks = await searchRelevantChunks(questionEmbedding, topK);

  // Extraemos solo los textos como contexto
  const contexts = chunks.map((c) => c.content);

  // 3) Llamar al LLM con pregunta + contextos
  const answer = await askLLM(question, contexts);

  return {
    answer,
    contexts: chunks, // por si luego quieres mostrar de dónde salió la info
  };
}

module.exports = {
  answerQuestionWithRAG,
};