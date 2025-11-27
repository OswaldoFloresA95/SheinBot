import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sheinbot/screens/mexico_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // ------------------ Slideshow ------------------
  final List<String> images = [
    "assets/images/beca.jpg",
    "assets/images/campo.jpg",
    "assets/images/ferro.png",
    "assets/images/salud.jpg",
  ];

  int currentIndex = 0;
  bool visible = true;
  late Timer _timer;

  // Offset para movimiento diagonal
  Offset _slideOffset = const Offset(-0.02, -0.01);
  bool _moveRight = true;

  @override
  void initState() {
    super.initState();

    // Animación tipo "Siri pulse"
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Slideshow con movimiento diagonal
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Primero hacemos fade out
      setState(() {
        visible = false;
      });

      // Después de que se apaga, cambiamos imagen y dirección de movimiento
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          currentIndex = (currentIndex + 1) % images.length;
          visible = true;

          // Alternar dirección diagonal
          _moveRight = !_moveRight;
          _slideOffset = _moveRight
              ? const Offset(0.03, 0.01) // derecha-abajo
              : const Offset(-0.03, -0.01); // izquierda-arriba
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ------------------ Fondo negro base ------------------
          Container(color: Colors.black),

          // ------------------ Imagen con movimiento diagonal + fade ------------------
          AnimatedSlide(
            offset: _slideOffset, // movimiento diagonal
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Image.asset(
                images[currentIndex],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ------------------ Degradado encima para contraste ------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(15, 13, 38, 0.75),
                  Color.fromRGBO(32, 17, 51, 0.65),
                  Color.fromRGBO(58, 20, 36, 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ------------------ Blur sutil sobre el fondo ------------------
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

          // ------------------ Contenido central ------------------
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 28,
                    spreadRadius: -6,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo superior
                  Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  // Kualli centrado
                  Image.asset(
                    "assets/images/dos.png",
                    height: 200,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Bienvenido al Explorador\nPlan México",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 214, 134),
                      letterSpacing: 0.6,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Recorre apoyos, capacitaciones y oportunidades en tu región acompañad@ de Kualli.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Animación tipo "Siri"
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.15).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const SpinKitPulse(
                      color: Color.fromARGB(255, 245, 208, 110),
                      size: 90,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Botón de comenzar con gradiente
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFC857),
                            Color(0xFFFD8060),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 38,
                            vertical: 18,
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlanMexicoScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.play_arrow_rounded,
                                size: 24, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Comenzar recorrido",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
}
