import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// MODELO POLO (top-level)
/// ------------------------------------------------------------
class Polo {
  final String nombre;
  final String estado;
  final String descripcion;
  final List<String> fotos;

  Polo({
    required this.nombre,
    required this.estado,
    required this.descripcion,
    required this.fotos,
  });
}

/// ------------------------------------------------------------
/// PANTALLA PRINCIPAL DE LOS POLOS
/// ------------------------------------------------------------
class PoloFrame extends StatefulWidget {
  const PoloFrame({super.key});

  @override
  State<PoloFrame> createState() => _PoloFrameState();
}

class _PoloFrameState extends State<PoloFrame> {
  // ------------------ LISTA DE POLOS ------------------
  final List<Polo> polosDelBienestar = [
    Polo(
      nombre: "Polo de Bienestar de Minatitlán",
      estado: "Veracruz",
      descripcion:
          "Fortalecer el desarrollo comunitario y apoyar proyectos productivos.",
      fotos: [
        "assets/images/polos/mina1.jpg",
        "assets/images/polos/mina2.jpg",
      ],
    ),
    Polo(
      nombre: "Polo de Bienestar de Ciudad Juárez",
      estado: "Chihuahua",
      descripcion:
          "Impulsa empleos dignos, capacitación y desarrollo regional.",
      fotos: [
        "assets/images/polos/juarez1.jpg",
        "assets/images/polos/juarez2.jpg",
      ],
    ),
    Polo(
      nombre: "Polo de Bienestar de Acapulco",
      estado: "Guerrero",
      descripcion:
          "Apoyo a reconstrucción, empleo temporal y reforzamiento económico local.",
      fotos: [
        "assets/images/polos/acapulco1.jpg",
        "assets/images/polos/acapulco2.jpg",
      ],
    ),
  ];

  // ------------------ CONTROLADORES ------------------
  int currentIndex = 0;
  final PageController photosController = PageController();

  void _nextPolo() {
    setState(() {
      currentIndex = (currentIndex + 1) % polosDelBienestar.length;
      photosController.jumpToPage(0);
    });
  }

  void _previousPolo() {
    setState(() {
      currentIndex =
          (currentIndex - 1 + polosDelBienestar.length) % polosDelBienestar.length;
      photosController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Polo poloActual = polosDelBienestar[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 142, 51, 51),
        title: const Text(
          "Polos del Bienestar",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ------------------ TÍTULO + ESTADO + FLECHAS ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: 40),
                  onPressed: _previousPolo,
                ),

                Expanded(
                  child: Column(
                    children: [
                      Text(
                        poloActual.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1A3B),
                        ),
                      ),
                      Text(
                        poloActual.estado,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_right, size: 40),
                  onPressed: _nextPolo,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ------------------ GALERÍA ------------------
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: photosController,
                itemCount: poloActual.fotos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        poloActual.fotos[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ DESCRIPCIÓN ------------------
            Text(
              poloActual.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
