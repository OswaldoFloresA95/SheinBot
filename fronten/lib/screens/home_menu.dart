import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  bool isMenuOpen = true;

  List<Map<String, String>> messages = [
    {
      "sender": "bot",
      "text": "¡Hola! Soy tu asistente. ¿En qué puedo ayudarte hoy?",
    },
  ];

  void addUserMessage(String text) {
    setState(() {
      messages.add({"sender": "user", "text": text});
    });
    scrollToBottom();
  }

  void addBotMessage(String text) {
    setState(() {
      messages.add({"sender": "bot", "text": text});
    });
    scrollToBottom();
  }

  final ScrollController _scrollController = ScrollController();

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

  /////////////// SPEECH TO TEXT 
  
  String partialText="";
  int? listeningMsgIndex;

  late stt.SpeechToText speech;
  bool isListening =false;
  @override
  void initState() {
    super.initState();
    speech=stt.SpeechToText();
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  void startListening() async{
    if (isListening) return;

    bool available = await speech.initialize(
      onStatus:(status) {},
      onError: (e)=> print("Error: $e"),
    );
    if(!available) return;
    
      setState(() {
        isListening = true;
        partialText ="";
        messages.add({"sender":"user", "text":""});
        listeningMsgIndex = messages.length -1;
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
        partialResults:true,
      );
    }
  

  void stopListening() async{
    if(!isListening) return;

    await speech.stop();
    setState(() {
      isListening = false;

      // remover mensaje temporal
      if (listeningMsgIndex != null) {
        messages.removeAt(listeningMsgIndex!);
      }
    });

    //guardar texto def
    final finalText = partialText.trim();

    //si hay texto, agregar mensaje real
    if(finalText.isNotEmpty){
      addUserMessage(finalText);
    }

    partialText="";
    listeningMsgIndex=null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ---------------------------------------------------
          // MENÚ ANIMADO
          // ---------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isMenuOpen ? 300 : 0,
            child: AnimatedOpacity(
              opacity: isMenuOpen ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFF3F6FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: isMenuOpen ? 28 : 0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1A3B),
                      ),
                      child: const Text("Menú"),
                    ),

                    const SizedBox(height: 25),

                    if (isMenuOpen) ...[
                      buildMenuButton("Información general"),
                      buildMenuButton("Zonas de desarrollo"),
                      buildMenuButton("Impacto social"),
                      buildMenuButton("Inversiones y proyectos"),
                      buildMenuButton("Contacto"),
                    ],

                    const Spacer(),

                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: isMenuOpen ? 14 : 0,
                        color: Colors.grey,
                      ),
                      child: const Text("Versión 1.0"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // PANEL DE CHAT
          // ---------------------------------------------------
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 10,
                left: 20,
                right: 20,
              ),
              child: Stack(
                children: [
                  // CHAT
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 200,

                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                      final msg = messages[index];

                      // NUEVAS LÍNEAS
                      //final bool isTemp = msg["sender"] == "user_temp"; 
                      final bool isBot = msg["sender"] == "bot";
                      //final bool isUser = msg["sender"] == "user";

                      //bool alignRight = isUser || isTemp;

                        
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment:
                                isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
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
                                    vertical: 14,
                                    horizontal: 18,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 330,
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: isMenuOpen ? 25 : 28,
                                      color: const Color(0xFF0A1A3B),
                                    ),
                                    child: Text(msg["text"]!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ---------------------------------------------------
                  // MASCOTA A LA IZQUIERDA
                  // ---------------------------------------------------
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset("assets/images/chat.jpeg", height: 180),
                  ),

                  // ---------------------------------------------------
                  // MICRÓFONO A LA DERECHA
                  // ---------------------------------------------------
                  Positioned(
                    bottom: 30,
                    right: 60,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isMenuOpen = false);

                        if(isListening){
                          stopListening();
                        }else{
                          startListening();
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 161, 60, 19),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                    ),
                  ),

                  // BOTÓN PARA ABRIR / CERRAR MENÚ
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isMenuOpen = !isMenuOpen);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black12,
                        ),
                        child: Icon(
                          isMenuOpen ? Icons.close : Icons.menu,
                          size: 30,
                          color: const Color(0xFF0A1A3B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BOTONES DE MENÚ
  // ---------------------------------------------------------
  Widget buildMenuButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF0A1A3B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COLITAS INVERTIDAS
// ---------------------------------------------------------
class BubblePainter extends CustomPainter {
  final bool isBot;
  final Color color;

  BubblePainter({required this.isBot, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      const Radius.circular(20),
    );
    canvas.drawRRect(rrect, paint);

    final path = Path();

    if (isBot) {
      // BOT → izquierda
      path.moveTo(15, size.height - 10);
      path.lineTo(-10, size.height - 5);
      path.lineTo(15, size.height - 28);
    } else {
      // USER → derecha
      path.moveTo(size.width - 15, size.height - 10);
      path.lineTo(size.width + 10, size.height - 5);
      path.lineTo(size.width - 15, size.height - 28);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
