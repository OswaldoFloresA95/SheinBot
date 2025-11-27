import 'package:flutter/material.dart';
import 'package:sheinbot/screens/home_menu.dart';
import 'package:sheinbot/screens/welcome_screen.dart';


void main() {
  runApp(const SheinBotApp());
}

class SheinBotApp extends StatelessWidget {
  const SheinBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorador Plan México',
      debugShowCheckedModeBanner: false,

      // Tema principal (puedes modificar colores aquí)
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(111, 24, 52, 1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromRGBO(111, 24, 52, 1),
          secondary: const Color.fromARGB(255, 221, 221, 221),
        ),
        fontFamily: 'Arial',
        
      ),

      // Pantalla inicial
      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/menu': (context) =>  HomeMenuScreen(),
      },
    );
  }
}

