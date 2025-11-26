// src/routes/ingest.routes.js

const express = require('express');
const router = express.Router();
const db = require('../db/index');
//  Importamos la función de tu servicio de embeddings.js (que ya es robusta)
const { getEmbedding } = require('../services/embeddings'); 

router.post('/', async (req, res) => {
    //    El código de inicialización de Gemini y verificación de clave se quitó de aquí.
    //    Esa lógica reside ahora en services/embeddings.js.
    
    const { text } = req.body;
    const url = 'manual_ingestion_' + Date.now(); 

    if (!text) {
        return res.status(400).json({ ok: false, error: "text requerido" });
    }

    try {
        // 1. Insertar el documento y obtener el ID
        const docInsert = 'INSERT INTO Documents (url, title, raw_content) VALUES ($1, $2, $3) RETURNING id';
        const docResult = await db.query(docInsert, [url, 'Texto Ingestado Manualmente', text]);
        const documentId = docResult.rows[0].id;
        
        // 2. Generar el embedding (vector) usando tu servicio
        //  Cambio: Llamamos a la función ya probada de tu archivo embeddings.js
        const embedding = await getEmbedding(text); 

        // 3. Formatear y preparar la inserción
        const embText = '[' + embedding.join(',') + ']';

        // 4. Insertar el chunk
        const chunkInsert = `
            INSERT INTO Chunks (document_id, content, embedding, position) 
            VALUES ($1, $2, $3::VECTOR(768), $4) 
            RETURNING id;
        `;
        const chunkResult = await db.query(chunkInsert, [documentId, text, embText, 1]);

        res.json({ 
            ok: true, 
            message: "Documento y chunk guardados correctamente.", 
            document_id: documentId,
            chunk_id: chunkResult.rows[0].id
        });

    } catch (error) {
        // Si hay un error, el log en services/embeddings.js nos dirá si es de API
        console.error('Error final en ingestión:', error.message);
        
        // Si tu servicio devuelve un error de clave, se lo pasamos al cliente.
        res.status(500).json({ 
            ok: false, 
            error: 'Error al procesar y guardar en BD: ' + error.message 
        });
    }
});

module.exports = router;