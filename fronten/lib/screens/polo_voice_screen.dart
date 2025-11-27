import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sheinbot/screens/polo_frame.dart';
import 'package:sheinbot/screens/mexico_screen.dart';

class PoloVoiceScreen extends StatefulWidget {
  const PoloVoiceScreen({super.key});

  @override
  State<PoloVoiceScreen> createState() => _PoloVoiceScreenState();
}

class _PoloVoiceScreenState extends State<PoloVoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _heardText = "";
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onError: (e) => debugPrint("STT error: $e"),
      onStatus: (s) => debugPrint("STT status: $s"),
    );
    if (!available) return;

    setState(() {
      _isListening = true;
      _heardText = "";
    });

    await _speech.listen(
      onResult: (res) {
        setState(() {
          _heardText = res.recognizedWords;
        });
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color.fromARGB(255, 142, 51, 51),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: const Center(
            child: Text(
              "PLAN MÉXICO",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Kualli chismoso asomándose a la derecha
          Positioned(
            bottom: 678,
            right: -100,
            child: Image.asset(
              "assets/images/kualli chismoso.png",
              height: 300,
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    _submitted ? "Respuesta enviada" : "¿Qué podríamos mejorar?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A1A3B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double rowWidth = constraints.maxWidth;
                      return SizedBox(
                        width: rowWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _heardText.isEmpty
                                      ? "Pulsa el micrófono para grabar tu retroalimentación."
                                      : _heardText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _submitted
                                  ? null
                                  : () {
                                      setState(() {
                                        _submitted = true;
                                        _isListening = false;
                                      });
                                      _speech.stop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "¡Gracias por tu retroalimentación!"),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 142, 51, 51),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Enviar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _submitted ? null : _toggleListening,
                    child: Opacity(
                      opacity: _submitted ? 0.5 : 1,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red.shade400
                              : Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitted
                        ? null
                        : () {
                            setState(() {
                              _heardText = "";
                              _isListening = false;
                            });
                            _speech.stop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Borrar",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flechas laterales: izquierda regresa a PoloFrame, derecha abre MexicoScreen
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 10,
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PoloFrame()),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 36,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PlanMexicoScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 36,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
