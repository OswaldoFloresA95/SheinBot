// src/services/embeddings.js
require("dotenv").config();
const { GoogleGenAI } = require("@google/genai");

// API key desde .env
const apiKey = process.env.EMBEDDINGS_API_KEY;
if (!apiKey) {
  console.warn(
    "[embeddings] EMBEDDINGS_API_KEY no está definida en el .env. " +
      "Las llamadas a getEmbedding van a fallar."
  );
}

// Cliente de Gemini
const genAI = new GoogleGenAI({ apiKey });

// Modelo de embeddings (por ahora gemini-embedding-001)
const embeddingModelName =
  process.env.EMBEDDINGS_DM || "gemini-embedding-001";

/**
 * Convierte un texto en un embedding (vector de floats).
 * Devuelve un array tipo [0.01, -0.02, ...] de longitud 3072 (en tu caso).
 */
async function getEmbedding(text) {
  if (!text || !text.trim()) {
    throw new Error("Texto vacío para embedding");
  }

  try {
    const response = await genAI.models.embedContent({
      model: embeddingModelName,
      contents: text, // puede ser string directo
    });

    const values = response.embeddings[0].values;

    console.log(
      "[embeddings] Dimensión:",
      values.length,
      "Modelo:",
      embeddingModelName
    );

    return values;
  } catch (err) {
      console.error("[embeddings] Error al obtener embedding:", err.message);
      throw new Error("Error al obtener embedding desde Gemini");
  }
}

module.exports = {
  getEmbedding,
};