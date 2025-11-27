import 'package:flutter/material.dart';
import 'package:sheinbot/screens/mexico_screen.dart';
import 'package:sheinbot/screens/polo_voice_screen.dart';

/// ------------------------------------------------------------
/// MODELO POLO (top-level)
/// ------------------------------------------------------------
class Polo {
  final String nombre;
  final String estado;
  final String descripcion;
  final List<String> fotos;
  final String qr;

  Polo({
    required this.nombre,
    required this.estado,
    required this.descripcion,
    required this.fotos,
    required this.qr,
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
      nombre: "Polo de Bienestar AIFA",
      estado: "Hidalgo",
      descripcion:
          "¡Desliza para ver fotos!  ¡Escanea el código QR para más información!",
      fotos: [
        "assets/images/polos/4.jpg",
        "assets/images/polos/5.jpg",
      ],
      qr: "assets/images/polos/polos.png",
    ),

    Polo(
      nombre: "Polo de Bienestar de Seybaplaya",
      estado: "Campeche",
      descripcion:
          "¡Desliza para ver fotos!  ¡Escanea el código QR para más información!",
      fotos: [
        "assets/images/polos/1.jpg",
        "assets/images/polos/2.jpg",
        "assets/images/polos/3.jpg",
      ],
      qr: "assets/images/polos/seybaplaya.png",
    ),
  ];

  // ------------------ CONTROLADORES ------------------
  int currentIndex = 0;
  final PageController photosController = PageController();

  void _nextPolo() {
    setState(() {
      currentIndex = (currentIndex + 1) % polosDelBienestar.length;
      photosController.jumpToPage(0); // reinicia galería
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
        automaticallyImplyLeading: false,
      ),

      body: Stack(
        children: [
          // ============================================================
          // CONTENIDO PRINCIPAL
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(40),
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
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1A3B),
                            ),
                          ),
                          Text(
                            poloActual.estado,
                            style: const TextStyle(
                              fontSize: 30,
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

                const SizedBox(height: 60),

                // ------------------ GALERÍA ------------------
                SizedBox(
                  height: 350,
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

                const SizedBox(height: 40),

                // ------------------ DESCRIPCIÓN ------------------
                Text(
                  poloActual.descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                ),

                const SizedBox(height: 20),

                // ------------------ QR CENTRADO ------------------
                if (poloActual.qr.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        "Escanea el código QR:",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: SizedBox(
                          height: 220,
                          child: Image.asset(
                            poloActual.qr,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ============================================================
          // FLECHA LATERAL PARA REGRESAR
          // ============================================================
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 10,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
                  Icons.arrow_back_ios,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Botón derecho para abrir un nuevo frame con micrófono
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PoloVoiceScreen()));
              },
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
                  size: 40,
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
