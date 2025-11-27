import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  //  IMPORTANTE: Si usas emulador Android, localhost es 10.0.2.2
  // Si usas iOS o Web, es localhost.
  // Si usas un celular físico, pon la IP de tu PC (ej. 192.168.1.50)
  static const String baseUrl = 'http://172.32.6.27:3000';
  // O usa 'http://localhost:3000' si vas a correr Flutter Web

  String _normalizeQuestion(String q) {
    // Quita espacios extra y pasa a minúsculas para ayudar a los embeddings/búsquedas.
    return q.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  Future<String> sendMessage(String question,
      {List<Map<String, String>>? history}) async {
    final url = Uri.parse('$baseUrl/chat');
    final normalized = _normalizeQuestion(question);
    // Debug para verificar qué se envía/recibe
    // ignore: avoid_print
    print('[chat] pregunta: "$normalized" -> $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': normalized, // El JSON que espera tu backend
          'history': history ?? [],
        }),
      );

      // ignore: avoid_print
      print('[chat] resp (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        // Decodificamos la respuesta
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'Respuesta vacía del servidor';
      }
      return 'Error del servidor: ${response.statusCode}';
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}
