import 'package:flutter/material.dart';
import '../services/chat_service.dart'; // Importa tu servicio

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService(); // Instancia del servicio
  
  // Lista para guardar el historial localmente
  final List<Map<String, String>> _messages = []; 
  bool _isLoading = false;

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Mostrar mensaje del usuario inmediatamente
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true; // Mostrar spinner
    });
    _controller.clear();

    // 2. Llamar al backend
    final response = await _chatService.sendMessage(text);

    // 3. Mostrar respuesta del bot
    setState(() {
      _messages.add({'sender': 'bot', 'text': response});
      _isLoading = false; // Ocultar spinner
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SheinBot 🇲🇽")),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          // Indicador de "Escribiendo..."
          if (_isLoading) LinearProgressIndicator(),
          
          // Campo de texto
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Pregunta sobre el Plan México..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading ? null : _handleSend,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}