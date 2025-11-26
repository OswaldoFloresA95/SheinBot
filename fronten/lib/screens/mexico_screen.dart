import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PlanMexicoScreen extends StatefulWidget {
  @override
  State<PlanMexicoScreen> createState() => _PlanMexicoScreenState();
}

class _PlanMexicoScreenState extends State<PlanMexicoScreen> {
  List<Map<String, String>> messages = [
    {
      "sender": "bot",
      "text": "¡Hola! Soy tu asistente. ¿En qué puedo ayudarte hoy?",
    },
  ];

  final ScrollController _scrollController = ScrollController();

  String partialText = "";
  int? listeningMsgIndex;
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    speech.stop();
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
    if (finalText.isNotEmpty) addUserMessage(finalText);

    partialText = "";
    listeningMsgIndex = null;
  }

  // ------------------ WIDGET BOTONES ------------------
  Widget buildIconButton(String imagePath, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color, // color personalizado
          ),
          child: Center(
            child: Image.asset(imagePath, width: 125, height: 125),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
      ],
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
                  color: const Color.fromARGB(255, 51, 134, 128),
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
                              "assets/images/mexico.png", "Obras en\ntu comunidad", Colors.purple.shade300),
                          buildIconButton(
                              "assets/images/datos.png", "Apoyos y\nservicios", const Color.fromARGB(255, 72, 177, 77)),
                          buildIconButton(
                              "assets/images/info.png", "Botón 3", const Color.fromARGB(255, 246, 163, 100)),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildIconButton(
                              "assets/images/planta.png", "Botón 4", Colors.orange.shade300),
                          buildIconButton(
                              "assets/images/chalan.png", "Botón 5", const Color.fromARGB(255, 133, 172, 249)),
                          buildIconButton(
                              "assets/images/mexico.png", "Botón 6", const Color.fromARGB(255, 175, 255, 118)),
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
                                  constraints: const BoxConstraints(maxWidth: 330),
                                  child: Text(msg["text"]!,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.black87)),
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
                      BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1)
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
