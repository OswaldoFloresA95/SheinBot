import 'dart:async';
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
    "assets/images/ferro.jpg",
    "assets/images/salud.jpg",
  ];
  int currentIndex = 0;
  bool visible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Controlador de animación tipo "Siri pulse"
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Inicializar slideshow
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        visible = false; // fade out
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          currentIndex = (currentIndex + 1) % images.length;
          visible = true; // fade in
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
          // ------------------ Slideshow de fondo ------------------
          Container(color: Colors.black),
          AnimatedOpacity(
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

          // ------------------ Fondo degradado semi-transparente ------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(111, 24, 52, 0.7),
                  Color.fromRGBO(46, 9, 24, 0.7)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ------------------ Contenido central ------------------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                // Texto bienvenida
                const Text(
                  "Bienvenido al Explorador del Plan México",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 197, 82),
                  ),
                ),

                const SizedBox(height: 30),

                // Animación tipo "Siri"
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.15).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const SpinKitPulse(
                    color: Color.fromARGB(255, 221, 221, 221),
                    size: 90,
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de comenzar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PlanMexicoScreen()));
                  },
                  child: const Text(
                    "Comenzar",
                    style: TextStyle(
                      color: Color.fromARGB(255, 67, 67, 67),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
