// src/services/embeddings.js - ÚLTIMO INTENTO DE SINTAXIS

require("dotenv").config();
const { GoogleGenAI } = require("@google/genai");

const apiKey = process.env.EMBEDDINGS_API_KEY;
if (!apiKey) {
    console.warn("[embeddings] EMBEDDINGS_API_KEY no está definida.");
}

const genAI = new GoogleGenAI({ apiKey }); 
const embeddingModelName = "text-embedding-004"; 

/**
 * Convierte un texto en un embedding (vector de floats).
 */
async function getEmbedding(text) {
    if (!text || !text.trim()) {
        throw new Error("Texto vacío para embedding");
    }

    try {
        // ⭐ USAMOS LA FUNCIÓN EMBEDCONTENT DE LA VERSIÓN RECIENTE
        const response = await genAI.embeddings.embedContent({
            model: embeddingModelName,
            content: text, // Sintaxis simple para texto único
        });

        // La respuesta de este endpoint es 'response.embedding.values'
        const values = response.embedding.values; 

        console.log(
            "[embeddings] Dimensión:",
            values.length,
            "Modelo:",
            embeddingModelName
        );

        return values;
    } catch (err) {
        console.error("[embeddings] Error al obtener embedding:", err.message);
        throw new Error("Error al obtener embedding desde Gemini: " + err.message);
    }
}

module.exports = {
    getEmbedding,
};