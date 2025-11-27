import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  //  IMPORTANTE: Si usas emulador Android, localhost es 10.0.2.2
  // Si usas iOS o Web, es localhost.
  // Si usas un celular físico, pon la IP de tu PC (ej. 192.168.1.50)
  static const String baseUrl = 'http://10.0.2.2:3000'; 
  // O usa 'http://localhost:3000' si vas a correr Flutter Web

  Future<String> sendMessage(String question) async {
    final url = Uri.parse('$baseUrl/chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question, // El JSON que espera tu backend
        }),
      );

      if (response.statusCode == 200) {
        // Decodificamos la respuesta
        final data = jsonDecode(response.body);
        return data['answer']; // Retornamos solo el texto de la respuesta
      } else {
        return 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}