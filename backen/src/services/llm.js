// src/services/llm.js

require("dotenv").config();
const axios = require("axios");

const apiKey = process.env.LLM_API_KEY || process.env.EMBEDDINGS_API_KEY;
if (!apiKey) {
  console.warn(
    "[llm] API KEY no definida. Configura LLM_API_KEY o EMBEDDINGS_API_KEY en .env"
  );
}

// Modelo por defecto (Gemini 1.5 Flash es rápido y barato para chats)
const llmModelName = process.env.LLM_MODEL || "gemini-1.5-flash";
const fallbackMessage =
  "Actualmente estoy recabando más información al respecto sobre ese tema. Puedo conectarte con un asesor humano o buscar temas relacionados. ¿Te interesaría saber sobre las becas disponibles o los nuevos empleos en tu zona?";

/**
 * Llama al LLM (Gemini) usando la pregunta y los contextos relevantes vía REST API.
 *
 * @param {string} question - Pregunta del usuario.
 * @param {string[]} contexts - Lista de textos (chunks) relevantes.
 * @returns {Promise<string>} - Respuesta en texto.
 */
async function askLLM(question, contexts, history = []) {
  if (!question || !question.trim()) {
    return fallbackMessage;
  }

  // 1. Preparar el contexto
  const hasContext = contexts && contexts.length > 0;
  const contextText = hasContext
    ? contexts.join("\n\n---\n\n")
    : fallbackMessage;

  // Historial breve (últimos 3 turnos)
  let historyText = "";
  if (Array.isArray(history) && history.length > 0) {
    const lastTurns = history.slice(-3);
    historyText = lastTurns
      .map((h) => {
        const u = h.user ? `Usuario: ${h.user}` : "";
        const b = h.bot ? `Kualli: ${h.bot}` : "";
        return [u, b].filter((s) => s.trim().length > 0).join("\n");
      })
      .filter((s) => s.trim().length > 0)
      .join("\n---\n");
  }

  // 2. Prompt del sistema:
  //    - Usa SIEMPRE el contexto como fuente principal
  //    - PERO si el contexto no alcanza, puede usar conocimiento general
  //    - Sin inventar detalles específicos que "parezcan" salir de los documentos
  const systemPrompt = `
Eres un asistente llamado "Kuali" (por el Plan México).
Respondes SIEMPRE en español neutral.

Tienes acceso a un CONTEXTO opcional con fragmentos de documentos del Plan México.

REGLAS:
1. Si el CONTEXTO contiene información relevante para la pregunta, úsalo como fuente principal (sin mencionar que viene de documentos).
2. Si el CONTEXTO no es suficiente o no habla de lo que te preguntan, evita inventar: responde exactamente "${fallbackMessage}".
3. No menciones palabras como "documentos", "fuentes" ni la palabra "contexto"; habla directo al usuario.
4. No inventes datos específicos (fechas, montos, nombres); si no los tienes con certeza, usa el fallback.
5. Si la pregunta es ambigua, pide aclaración breve antes de responder.
`.trim();

  const userPrompt = `
CONTEXTO:
"""
${contextText}
"""

${historyText ? `HISTORIAL (últimos turnos):\n${historyText}\n` : ""}

PREGUNTA DEL USUARIO:
${question}
`.trim();

  // 3. Preparar la llamada REST a Gemini
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${llmModelName}:generateContent?key=${apiKey}`;

  const body = {
    // Instrucción de sistema separada (mejor que mezclar todo en un solo texto)
    systemInstruction: {
      role: "system",
      parts: [{ text: systemPrompt }],
    },
    contents: [
      {
        role: "user",
        parts: [{ text: userPrompt }],
      },
    ],
    generationConfig: {
      temperature: 0.3,      // bajo = más fiel al contexto
      maxOutputTokens: 500,
    },
  };

  try {
    const response = await axios.post(url, body, {
      headers: { "Content-Type": "application/json" },
    });

    const candidate = response.data.candidates?.[0];
    const text = candidate?.content?.parts?.[0]?.text || "";
    return text.trim().length === 0 ? fallbackMessage : text;
  } catch (err) {
    const msg = err.response?.data?.error?.message || err.message;
    console.error("[llm] Error al llamar al LLM:", msg);
    return fallbackMessage;
  }
}

module.exports = {
  askLLM,
};
