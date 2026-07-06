import 'package:flutter/material.dart';

import '../models/comparacion.dart';
import '../services/comparador_service.dart';

class ComparacionPage extends StatefulWidget {
  const ComparacionPage({super.key});

  @override
  State<ComparacionPage> createState() => _ComparacionPageState();
}

class _ComparacionPageState extends State<ComparacionPage> {
  final ComparadorService comparadorService = ComparadorService();

  List<Comparacion> comparaciones = [];

  int aumentos = 0;
  int bajas = 0;
  int nuevos = 0;
  int iguales = 0;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    comparaciones = await comparadorService.obtenerComparacion();

    aumentos = await comparadorService.cantidadAumentos();
    bajas = await comparadorService.cantidadBajas();
    nuevos = await comparadorService.cantidadNuevos();
    iguales = await comparadorService.cantidadIguales();

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'AUMENTO':
        return Colors.green;

      case 'BAJA':
        return Colors.red;

      case 'NUEVO':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado) {
      case 'AUMENTO':
        return Icons.arrow_upward;

      case 'BAJA':
        return Icons.arrow_downward;

      case 'NUEVO':
        return Icons.fiber_new;

      default:
        return Icons.remove;
    }
  }

  Widget tarjeta(
    String titulo,
    int valor,
    Color color,
  ) {
    return Card(
      child: SizedBox(
        width: 170,
        height: 90,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                valor.toString(),
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparación de precios"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              tarjeta("Aumentos", aumentos, Colors.green),
              tarjeta("Bajas", bajas, Colors.red),
              tarjeta("Nuevos", nuevos, Colors.blue),
              tarjeta("Sin cambios", iguales, Colors.grey),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: comparaciones.length,
              itemBuilder: (context, index) {
                final item = comparaciones[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(
                      iconoEstado(item.estado),
                      color: colorEstado(item.estado),
                    ),
                    title: Text(item.descripcion),
                    subtitle: Text(
                      "Código: ${item.codigo}\n"
                      "Antes: \$${item.precioViejo.toStringAsFixed(2)}\n"
                      "Ahora: \$${item.precioNuevo.toStringAsFixed(2)}",
                    ),
                    trailing: Text(
                      item.estado,
                      style: TextStyle(
                        color: colorEstado(item.estado),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "En el próximo paso actualizaremos automáticamente la base de datos.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text("ACTUALIZAR BASE DE DATOS"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}