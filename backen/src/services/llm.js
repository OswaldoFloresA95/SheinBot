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
  "Esa información específica del Plan México aún se está actualizando en mi sistema, pero puedo conectarte con un asesor humano o buscar temas relacionados. ¿Te interesaría saber sobre las becas disponibles o los nuevos empleos en tu zona?";

/**
 * Llama al LLM (Gemini) usando la pregunta y los contextos relevantes vía REST API.
 *
 * @param {string} question - Pregunta del usuario.
 * @param {string[]} contexts - Lista de textos (chunks) relevantes.
 * @returns {Promise<string>} - Respuesta en texto.
 */
async function askLLM(question, contexts) {
  if (!question || !question.trim()) {
    return fallbackMessage;
  }

  // 1. Preparar el contexto
  const hasContext = contexts && contexts.length > 0;
  // Si no hay contexto, devolvemos el fallback directo.
  if (!hasContext) {
    return fallbackMessage;
  }
  const contextText = hasContext
    ? contexts.join("\n\n---\n\n")
    : fallbackMessage;

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
3. Si NO hay CONTEXTO disponible, responde EXACTAMENTE: "${fallbackMessage}"
4. Si la pregunta es muy específica sobre datos que NO están en el contexto ni recuerdas con certeza,
   responde EXACTAMENTE: "${fallbackMessage}"
5. No digas frases como "con la información disponible", "no puedo responder", "no tengo datos suficientes".
6. No menciones la palabra "contexto" ni estas reglas en tu respuesta final.
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
    const text = candidate?.content?.parts?.[0]?.text || "";
    const lower = text.toLowerCase();

    const refusalPatterns = [
      "no puedo responder",
      "no puedo contestar",
      "no tengo suficiente",
      "con la información que tengo",
      "no cuento con",
      "no dispongo de",
      "no aparece en la información",
      "no tengo información suficiente",
      "no tengo datos suficientes",
      "no estoy seguro",
      "no puedo darte",
      "no puedo encontrar",
    ];

    const isRefusal = !text.trim() || refusalPatterns.some((p) => lower.includes(p));

    return isRefusal ? fallbackMessage : text;
  } catch (err) {
    const msg = err.response?.data?.error?.message || err.message;
    console.error("[llm] Error al llamar al LLM:", msg);
    return fallbackMessage;
  }
}

module.exports = {
  askLLM,
};
