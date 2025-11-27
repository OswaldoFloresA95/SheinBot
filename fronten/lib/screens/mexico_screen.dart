import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sheinbot/screens/polo_frame.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chat_service.dart';

class PlanMexicoScreen extends StatefulWidget {
  @override
  State<PlanMexicoScreen> createState() => _PlanMexicoScreenState();
}

class _PlanMexicoScreenState extends State<PlanMexicoScreen> {
  List<Map<String, String>> messages = [
    {"sender": "bot", "text": "¡Hola! Soy Kualli. "},
  ];

  final ScrollController _scrollController = ScrollController();

  String partialText = "";
  int? listeningMsgIndex;
  int? _typingMsgIndex;
  late stt.SpeechToText speech;
  bool isListening = false;
  bool _isStopping = false;
  bool _botTyping = false;
  final ChatService _chatService = ChatService();
  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<String> _miniFrameText = ValueNotifier<String>(
    "Aquí podrás ver más información relacionada con esta sección.",
  );
  final Map<String, String> miniTexts = {
    "Plan México\n":
        "El Plan México es una estrategia nacional que busca impulsar el crecimiento del país y mejorar la vida de las personas. \n\n¿Cómo lo hace?\n∘ Creando más empleos y fortaleciendo la industria mexicana.\n ∘ Atrayendo inversiones para construir carreteras, trenes, puertos, energía y más infraestructura.\n∘ Aumentando la producción en México, para depender menos del extranjero.\n∘ Impulsando la educación, ciencia y tecnología, para que más personas tengan oportunidades de estudiar y trabajar.\n∘ Reduciendo desigualdades, llevando desarrollo a todas las regiones del país.",

    "Polos de\nBienestar":
        "Los Polos del Bienestar son espacios creados en diferentes regiones de México donde se desarrollan proyectos que impulsan el crecimiento económico y social.\nSu idea principal es llevar oportunidades a zonas que antes tenían poco apoyo, para que más personas puedan trabajar, aprender y mejorar su calidad de vida sin tener que mudarse lejos.",

    "Apoyos\nEconómicos":
        "El gobierno de México ofrece una variedad de programas de apoyo económico a través de la Secretaría del Bienestar, destinados a reducir la pobreza y mejorar el bienestar de la población.\n\nProgramas de Bienestar\n∘ Pensión para Adultos Mayores: Dirigido a personas de 65 años o más, sin importar su condición laboral.\n∘ Sembrando Vida: Proporciona apoyos económicos y en especie a sujetos agrarios mayores de edad.\n∘ Becas para Educación: Becas a estudiantes de educación básica, media superior y superior.\n∘ Apoyos para Madres Trabajadoras: Apoyo a madres trabajadoras.",

    "Sitio Web":
        "Escanea el QR para acceder al sitio oficial del Plan México y conocer requisitos, apoyos y enlaces útiles.",

    "Construcción de\nCarreteras":
        "Plan México impulsa la red carretera y logística con 8 proyectos (1,970 km) y mantenimiento por 34,348 mdp en 2025. Se modernizan ejes troncales, libramientos y tramos clave (Pachuca-Huejutla, Tepic-Compostela, Mitla-Tehuantepec), además de caminos artesanales y expansión aeroportuaria.\n\nObjetivos\n∘ Conectar Polos de Bienestar con puertos y fronteras\n∘ Restaurar 44 mil km de red federal (programa “Bachetón”)\n∘ Mejorar conectividad para turismo, comercio y comunidades",

    "Empleos en mi\nLocalidad":
        "\"Jóvenes Construyendo el Futuro\" es un programa del Gobierno de México que ofrece capacitación laboral y apoyo económico a jóvenes de entre 18 y 29.\nEl programa tiene como objetivo principal brindar oportunidades de desarrollo profesional a jóvenes, ayudándoles a adquirir habilidades y experiencia laboral en diferentes sectores.\n\nBeneficios de los Participantes\n∘ Apoyo económico\n∘ Seguro medico\n∘ Capacitación\n\nOportunidades Laborales\n∘ Trabajos Administrativos\n∘ Ventas y Comercio\n∘ Oficios",
  };

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _initTts();
  }

  @override
  void dispose() {
    speech.stop();
    _tts.stop();
    _miniFrameText.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("es-MX");
    await _tts.setPitch(1.4); // tono más agudo/adorable
    await _tts.setSpeechRate(0.45); // ritmo un poco más lento
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
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

  void _startTypingPlaceholder() {
    setState(() {
      _botTyping = true;
      messages.add({"sender": "bot", "text": "..."});
      _typingMsgIndex = messages.length - 1;
      if (messages.length > 20) messages.removeAt(0);
    });
    scrollToBottom();
  }

  Future<bool> _typeOutText(
    String fullText, {
    Duration step = const Duration(milliseconds: 80),
  }) async {
    if (_typingMsgIndex == null) return false;
    final words = fullText.split(RegExp(r'\\s+')).where((w) => w.isNotEmpty);
    String current = "";
    bool wrote = false;
    for (final word in words) {
      current = (current + " " + word).trim();
      if (_typingMsgIndex == null) break;
      setState(() {
        messages[_typingMsgIndex!]["text"] = current;
      });
      wrote = true;
      await Future.delayed(step);
    }
    setState(() {
      _botTyping = false;
      _typingMsgIndex = null;
    });
    return wrote;
  }

  String _shortenResponse(
    String text, {
    int maxWords = 60,
    int minFirstSentenceWords = 8,
  }) {
    // Separa por punto/exclamación/interrogación aun sin espacio después.
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.isNotEmpty) {
      final first = sentences.first;
      final firstWordCount = first.split(RegExp(r'\s+')).length;

      // Si la primera oración es muy corta y hay otra, combinar ambas.
      if (firstWordCount < minFirstSentenceWords && sentences.length > 1) {
        final combined = '$first ${sentences[1]}'.trim();
        final combinedWords = combined.split(RegExp(r'\s+'));
        if (combinedWords.length <= maxWords) {
          return combined;
        }
        return combinedWords.take(maxWords).join(' ') + '...';
      }

      if (firstWordCount <= maxWords) return first;
    }

    // Si no hay puntos o es muy largo, recorta por número de palabras.
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
    if (logInChat) _startTypingPlaceholder();
    try {
      final response = await _chatService.sendMessage(query);
      if (updateMini) {
        _miniFrameText.value = _shortenResponse(
          response,
          maxWords: miniMaxWords,
        );
      }
      if (logInChat) {
        final shortened = _shortenResponse(response, maxWords: botMaxWords);
        final typed = await _typeOutText(shortened);
        if (!typed) addBotMessage(shortened);
      }
    } catch (e) {
      if (updateMini) _miniFrameText.value = "Error de conexión: $e";
      if (logInChat) addBotMessage("Error de conexión: $e");
    }
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
      onStatus: (status) {
        // Cuando el reconocimiento termina por tiempo/silencio, enviamos lo capturado.
        if (status == "notListening") {
          stopListening();
        }
      },
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
    if (!isListening || _isStopping) return;
    _isStopping = true;

    await speech.stop();
    setState(() {
      isListening = false;
      if (listeningMsgIndex != null) messages.removeAt(listeningMsgIndex!);
    });

    final finalText = partialText.trim();
    if (finalText.isNotEmpty) await _sendToBackend(finalText);

    partialText = "";
    listeningMsgIndex = null;
    _isStopping = false;
  }

  // ------------------ MINI FRAME SOBRE LOS BOTONES ------------------
  void _openMiniFrame(String title) {
    // Toma el texto definido para este botón; editable en miniTexts.
    _miniFrameText.value =
        miniTexts[title] ??
        "Aquí podrás ver más información relacionada con esta sección.";

    final bool isSitioWeb = title.trim().startsWith("Sitio Web");

    // TTS para el botón Plan México
    if (title.trim().startsWith("Plan México")) {
      _speak(
        "El Plan México quiere que México sea más fuerte, más justo y con mejores oportunidades para todas y todos.",
      );
    }

    if (title.trim().startsWith("Apoyos\nEconómicos")) {
      _speak("A continuación te muestro las opciones de apoyos económicos que nos ofrece el gobierno.");
    }
    if (title.trim().startsWith("Empleos en mi\nLocalidad")) {
      _speak("Gracias al Programa Jóvenes construyendo el futuro miles de jóvenes mexicanos podrán capacitarse mientras trabajan en empleos de su localidad.");
    }
    if (title.trim().startsWith("Polos de\nBienestar")) {
      _speak("WiWiWi");
    }
    if (title.trim().startsWith("Construcción de\nCarreteras")) {
      _speak("Éstas son algunas de las carreteras que se han construido y remodelado con el plan México.");
    }

    final size = MediaQuery.of(context).size; // ancho/alto de la pantalla
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.9, // antes 360
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
                        if (isSitioWeb)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _miniFrameText.value.isNotEmpty
                                    ? _miniFrameText.value
                                    : "Escanea el código para visitar el sitio.",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Image.asset(
                                  "assets/images/qr.jpeg",
                                  height: 320,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          )
                        else
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
                    child: Image.asset("assets/images/pc.jpeg", height: 180),
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color, // color personalizado
            ),
            child: Center(child: Icon(icon, size: 50, color: Colors.white)),
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

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
                            Icons.language_rounded,
                            "Sitio Web",
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
                      reverse: true,
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
                                      : const Color.fromARGB(
                                          255,
                                          254,
                                          241,
                                          143,
                                        ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 18,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 330,
                                  ),
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

                const SizedBox(height: 130),
              ],
            ),

            // 🔽🔽🔽🔽🔽🔽 NUEVA FLECHA A MITAD DE PANTALLA 🔽🔽🔽🔽🔽🔽
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45, // mitad vertical
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PoloFrame()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 40,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // 🔼🔼🔼🔼🔼🔼 FIN DE LA FLECHA 🔼🔼🔼🔼🔼🔼

            // ------------------ MASCOTA ------------------
            Positioned(
              bottom: 0,
              left: -20, // más hacia la izquierda
              child: Image.asset("assets/images/kualli.gif", height: 200),
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
                      ),
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
