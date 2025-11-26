import 'package:flutter/material.dart';
import 'package:sheinbot/screens/home_menu.dart';
 

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // --- CONTENIDO PRINCIPAL ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                menuButton(context, "Obras en tu Comunidad"),
                SizedBox(height: 25),
                menuButton(context, "Empleos y Capacitación"),
                SizedBox(height: 25),
                menuButton(context, "Apoyos y Servicios"),
                SizedBox(height: 25),
                menuButton(context, "Datos de tu municipio"),
              ],
            ),
          ),

          // --- MASCOTA BOTÓN (ESQUINA INFERIOR DERECHA) ---
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomeMenuScreen()),
                );
              },
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset("assets/images/chat.jpeg"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuButton(BuildContext context, String text) {
    return Container(
      width: 300,
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF0A1A3B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
