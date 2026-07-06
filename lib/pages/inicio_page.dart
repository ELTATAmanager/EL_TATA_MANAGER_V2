import 'package:flutter/material.dart';

import '../services/csv_service.dart';
import 'comparacion_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final CsvService csvService = CsvService();

  bool cargando = false;

  Future<void> analizar() async {
    setState(() {
      cargando = true;
    });

    try {
      final cantidad = await csvService.analizarArchivo();

      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      if (cantidad == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No se seleccionó ningún archivo.",
            ),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ComparacionPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EL TATA Manager"),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.store,
                    color: Colors.orange,
                    size: 90,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "EL TATA Manager",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Comparador inteligente de listas de precios",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: cargando ? null : analizar,
                      icon: const Icon(Icons.analytics),
                      label: const Text(
                        "ANALIZAR LISTA",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (cargando)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}