import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sheinbot/screens/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Controlador de animación tipo "Siri pulse"
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo (puedes reemplazar más tarde con un video o animación)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(111, 24, 52,1), Color.fromRGBO(46, 9, 24,1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Contenido central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o icono inicial
                
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),

               // const SizedBox(height: 5),

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
                    // Aquí irá la navegación hacia el home o IA
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> MainMenuScreen()));
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
