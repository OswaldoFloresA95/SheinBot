import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Importar TTS
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _apiService = ChatService();
  
  //  1. Instancia del motor de voz
  final FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //  2. Configurar la voz al iniciar
    _initTts();
  }

  //  Configuración inicial de la voz
  void _initTts() async {
    await _flutterTts.setLanguage("es-MX"); // Español de México
    await _flutterTts.setPitch(1.0);        // Tono normal
    await _flutterTts.setSpeechRate(0.5);   // Velocidad normal
  }

  //  Función para hablar
  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  //  Función para detener la voz (por si habla mucho)
  void _stopSpeaking() async {
    await _flutterTts.stop();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    // Detener si estaba hablando algo anterior
    _stopSpeaking(); 

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _textController.clear();

    // Llamar al backend
    final response = await _apiService.sendMessage(text);

    setState(() {
      _messages.add({'role': 'bot', 'text': response});
      _isLoading = false;
    });

    //  3. ¡HABLAR LA RESPUESTA!
    _speak(response);
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Detener voz al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SheinBot 🇲🇽'),
        backgroundColor: Colors.teal,
        actions: [
          //  Botón opcional para callar al bot si habla mucho
          IconButton(
            icon: const Icon(Icons.volume_off),
            onPressed: _stopSpeaking,
            tooltip: "Detener voz",
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Pregunta sobre el Plan México...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  iconSize: 32,
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}