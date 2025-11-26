// src/services/llm.js

require("dotenv").config();
const axios = require("axios"); // Usamos axios para ir a lo seguro

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

  // 1. Preparar el Prompt (Igual que en tu código, que estaba muy bien)
  const contextText =
    contexts && contexts.length
      ? contexts.join("\n\n---\n\n")
      : "NO HAY CONTEXTO DISPONIBLE DE LA BASE DE DATOS.";

  const systemPrompt = `
Eres un asistente inteligente llamado "SheinBot" (por el Plan México).
Tu objetivo es responder preguntas basándote EXCLUSIVAMENTE en la información proporcionada en el CONTEXTO.

REGLAS:
1. Si la respuesta está en el contexto, responde de forma clara, amable y concisa.
2. Si la información NO está en el contexto, di: "Lo siento, no tengo información sobre eso en mis documentos del Plan México."
3. No inventes datos.
`.trim();

  const userPrompt = `
CONTEXTO:
"""
${contextText}
"""

PREGUNTA DEL USUARIO:
${question}
`.trim();

  // 2. Preparar la llamada REST a Gemini
  // Endpoint: generateContent
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${llmModelName}:generateContent?key=${apiKey}`;

  const body = {
    contents: [
      {
        parts: [
          { text: systemPrompt + "\n\n" + userPrompt } 
          // Gemini funciona bien concatenando instrucciones y usuario en un solo bloque de texto
        ]
      }
    ],
    generationConfig: {
        temperature: 0.3, // Bajo para que sea fiel al contexto
        maxOutputTokens: 500
    }
  };

  try {
    const response = await axios.post(url, body, {
      headers: { "Content-Type": "application/json" }
    });

    // 3. Extraer la respuesta
    // Estructura: data.candidates[0].content.parts[0].text
    const candidate = response.data.candidates?.[0];
    const text = candidate?.content?.parts?.[0]?.text;

    return text || "No pude generar una respuesta (La API devolvió vacío).";

  } catch (err) {
    const msg = err.response?.data?.error?.message || err.message;
    console.error("[llm] Error al llamar al LLM:", msg);
    throw new Error("Error al generar respuesta: " + msg);
  }
}

module.exports = {
  askLLM,
};