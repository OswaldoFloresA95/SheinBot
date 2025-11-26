// src/services/llm.js
require("dotenv").config();
const { GoogleGenAI } = require("@google/genai");

const apiKey = process.env.LLM_API_KEY || process.env.EMBEDDINGS_API_KEY;
if (!apiKey) {
  console.warn(
    "[llm] LLM_API_KEY no está definida. Usa la misma que EMBEDDINGS_API_KEY o configúrala en .env"
  );
}

const genAI = new GoogleGenAI({ apiKey });

// Modelo por defecto
const llmModelName = process.env.LLM_MODEL || "gemini-1.5-flash";

/**
 * Llama al LLM (Gemini) usando la pregunta y los contextos relevantes.
 *
 * @param {string} question - Pregunta del usuario.
 * @param {string[]} contexts - Lista de textos (chunks) relevantes.
 * @returns {Promise<string>} - Respuesta en texto.
 */
async function askLLM(question, contexts) {
  if (!question || !question.trim()) {
    throw new Error("Pregunta vacía para el LLM");
  }

  const contextText =
    contexts && contexts.length
      ? contexts.join("\n\n---\n\n")
      : "NO HAY CONTEXTO DISPONIBLE.";

  const systemPrompt = `
Eres un asistente que responde SOLO con la información del contexto.
Si la información no está en el contexto, responde algo como:
"No encuentro esa información en las fuentes que tengo."

Responde de forma clara y concisa, en español neutral.
`.trim();

  const userPrompt = `
CONTEXTO:
${contextText}

PREGUNTA DEL USUARIO:
${question}
`.trim();

  const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;

  try {
    const response = await genAI.models.generateContent({
      model: llmModelName,
      contents: fullPrompt, // en el SDK nuevo puedes mandar solo un string
    });

    const text = (response.text || "").trim();
    return text || "No pude generar una respuesta.";
  } catch (err) {
    console.error("[llm] Error al llamar al LLM:", err.message);
    throw new Error("Error al generar respuesta desde el modelo de lenguaje");
  }
}

module.exports = {
  askLLM,
};