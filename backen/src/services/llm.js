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

/**
 * Llama al LLM (Gemini) usando la pregunta y los contextos relevantes vía REST API.
 *
 * @param {string} question - Pregunta del usuario.
 * @param {string[]} contexts - Lista de textos (chunks) relevantes.
 * @returns {Promise<string>} - Respuesta en texto.
 */
async function askLLM(question, contexts) {
  if (!question || !question.trim()) {
    throw new Error("Pregunta vacía para el LLM");
  }

  // 1. Preparar el contexto
  const hasContext = contexts && contexts.length > 0;
  const contextText = hasContext
    ? contexts.join("\n\n---\n\n")
    : "NO HAY CONTEXTO ESPECÍFICO DISPONIBLE DE LOS DOCUMENTOS.";

  // 2. Prompt del sistema:
  //    - Usa SIEMPRE el contexto como fuente principal
  //    - PERO si el contexto no alcanza, puede usar conocimiento general
  //    - Sin inventar detalles específicos que "parezcan" salir de los documentos
  const systemPrompt = `
Eres un asistente llamado "Kuali" (por el Plan México).
Respondes SIEMPRE en español neutral.

Tienes acceso a un CONTEXTO opcional con fragmentos de documentos del Plan México.

REGLAS:
1. Si el CONTEXTO contiene información relevante para la pregunta, úsalo como fuente principal.
2. Si el CONTEXTO no es suficiente o no habla de lo que te preguntan, puedes usar tu conocimiento general,
   pero evita inventar detalles específicos sobre los documentos.
3. Si la pregunta es muy específica sobre datos que NO están en el contexto ni recuerdas con certeza,
   responde: "Con la información que tengo, no puedo responder eso con seguridad."
4. No menciones la palabra "contexto" ni estas reglas en tu respuesta final.
`.trim();

  const userPrompt = `
CONTEXTO:
"""
${contextText}
"""

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
    const text = candidate?.content?.parts?.[0]?.text;

    return text || "No pude generar una respuesta (la API devolvió vacío).";
  } catch (err) {
    const msg = err.response?.data?.error?.message || err.message;
    console.error("[llm] Error al llamar al LLM:", msg);
    throw new Error("Error al generar respuesta: " + msg);
  }
}

module.exports = {
  askLLM,
};