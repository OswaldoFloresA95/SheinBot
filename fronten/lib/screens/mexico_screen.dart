import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chat_service.dart';

class PlanMexicoScreen extends StatefulWidget {
  @override
  State<PlanMexicoScreen> createState() => _PlanMexicoScreenState();
}

class _PlanMexicoScreenState extends State<PlanMexicoScreen> {
  List<Map<String, String>> messages = [
    {
      "sender": "bot",
      "text": "¡Hola! Soy Kualli. ¿Conoces acerca del PLAN MÉXICO?",
    },
  ];

  final ScrollController _scrollController = ScrollController();

  String partialText = "";
  int? listeningMsgIndex;
  late stt.SpeechToText speech;
  bool isListening = false;
  final ChatService _chatService = ChatService();
  final ValueNotifier<String> _miniFrameText = ValueNotifier<String>(
      "Aquí podrás ver más información relacionada con esta sección.");

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    speech.stop();
    _miniFrameText.dispose();
    super.dispose();
  }

  void addUserMessage(String text) {
    setState(() {
      messages.add({"sender": "user", "text": text});
      if (messages.length > 20) messages.removeAt(0); // Limitar mensajes
    });
    scrollToBottom();
  }

  void addBotMessage(String text) {
    setState(() {
      messages.add({"sender": "bot", "text": text});
      if (messages.length > 20) messages.removeAt(0);
    });
    scrollToBottom();
  }

  String _trimWords(String text, int maxWords) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text;
    return words.take(maxWords).join(' ') + '...';
  }

  Future<void> _sendToBackend(
    String text, {
    bool updateMini = false,
    bool logInChat = true,
    int miniMaxWords = 60,
    int botMaxWords = 60,
  }) async {
    final query = text.trim();
    if (query.isEmpty) return;
    if (logInChat) addUserMessage(query);
    final response = await _chatService.sendMessage(query);
    if (updateMini) {
      _miniFrameText.value = _trimWords(response, miniMaxWords);
    }
    if (logInChat) addBotMessage(_trimWords(response, botMaxWords));
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ------------------ SPEECH TO TEXT ------------------
  void startListening() async {
    if (isListening) return;

    bool available = await speech.initialize(
      onStatus: (status) {},
      onError: (e) => print("Error: $e"),
    );
    if (!available) return;

    setState(() {
      isListening = true;
      partialText = "";
      messages.add({"sender": "user", "text": ""});
      listeningMsgIndex = messages.length - 1;
    });

    scrollToBottom();

    speech.listen(
      onResult: (result) {
        setState(() {
          partialText = result.recognizedWords;
          messages[listeningMsgIndex!]["text"] = partialText;
        });
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
    );
  }

  void stopListening() async {
    if (!isListening) return;

    await speech.stop();
    setState(() {
      isListening = false;
      if (listeningMsgIndex != null) messages.removeAt(listeningMsgIndex!);
    });

    final finalText = partialText.trim();
    if (finalText.isNotEmpty) await _sendToBackend(finalText);

    partialText = "";
    listeningMsgIndex = null;
  }

  // ------------------ MINI FRAME SOBRE LOS BOTONES ------------------
  void _openMiniFrame(String title) {
    _miniFrameText.value = 'Consultando sobre "$title"...';
    _sendToBackend(title, updateMini: true, logInChat: false);

    final size = MediaQuery.of(context).size; // ancho/alto de la pantalla
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.9,   // antes 360
            height: size.height * 0.6,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1A3B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<String>(
                          valueListenable: _miniFrameText,
                          builder: (_, value, __) {
                            return Text(
                              value,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Image.asset(
                      "assets/images/pc.jpeg",
                      height: 180,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------ WIDGET BOTONES ------------------
  Widget buildIconButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        _openMiniFrame(label);
      },
      child: Column(
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color, // color personalizado
            ),
            child: Center(
              child: Icon(
                icon,
                size: 90,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ------------------ TITULO ------------------
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 142, 51, 51),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "-- PLAN MÉXICO --",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // separación extra entre título y botones

                // ------------------ BOTONES ------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildIconButton(
                            Icons.flag_rounded,
                            "Plan México\n",
                            const Color.fromARGB(255, 213, 112, 112),
                          ),
                          buildIconButton(
                            Icons.location_city_rounded,
                            "Polos de\nBienestar",
                            const Color.fromARGB(255, 184, 81, 81),
                          ),
                          buildIconButton(
                            Icons.volunteer_activism_rounded,
                            "Apoyos\nEconómicos",
                            const Color.fromARGB(255, 142, 51, 51),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildIconButton(
                            Icons.school_rounded,
                            "Capacitaciones\n",
                            const Color.fromARGB(255, 142, 51, 51),
                          ),
                          buildIconButton(
                            Icons.alt_route_rounded,
                            "Construcción de\nCarreteras",
                            const Color.fromARGB(255, 184, 81, 81),
                          ),
                          buildIconButton(
                            Icons.work_rounded,
                            "Empleos en mi\nLocalidad",
                            const Color.fromARGB(255, 213, 112, 112),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------ LISTA DE MENSAJES ------------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true, // mensajes desde abajo hacia arriba
                      padding: const EdgeInsets.only(top: 10, bottom: 100),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        final bool isBot = msg["sender"] == "bot";
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: isBot
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              CustomPaint(
                                painter: BubblePainter(
                                  isBot: isBot,
                                  color: isBot
                                      ? const Color.fromARGB(255, 249, 176, 142)
                                      : const Color.fromARGB(255, 254, 241, 143),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 18),
                                  constraints:
                                      const BoxConstraints(maxWidth: 330),
                                  child: Text(
                                    msg["text"]!,
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 130), // espacio para mic y mascota
              ],
            ),

            // ------------------ MASCOTA ------------------
            Positioned(
              bottom: 0,
              left: 15,
              child: Image.asset("assets/images/chat.jpeg", height: 200),
            ),

            // ------------------ MICRÓFONO ------------------
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (isListening) {
                    stopListening();
                  } else {
                    startListening();
                  }
                },
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Icon(Icons.mic, color: Colors.white, size: 80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ COLITAS DE LOS MENSAJES ------------------
class BubblePainter extends CustomPainter {
  final bool isBot;
  final Color color;

  BubblePainter({required this.isBot, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final rrect =
        RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(20));
    canvas.drawRRect(rrect, paint);

    final path = Path();
    if (isBot) {
      path.moveTo(15, size.height - 10);
      path.lineTo(-10, size.height - 5);
      path.lineTo(15, size.height - 28);
    } else {
      path.moveTo(size.width - 15, size.height - 10);
      path.lineTo(size.width + 10, size.height - 5);
      path.lineTo(size.width - 15, size.height - 28);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
