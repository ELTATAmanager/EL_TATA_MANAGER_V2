import 'package:flutter/material.dart';
import '../models/comparacion.dart';
import '../services/comparador_service.dart';
import '../services/csv_service.dart';

class ComparacionPage extends StatefulWidget {
  const ComparacionPage({super.key});

  @override
  State<ComparacionPage> createState() => _ComparacionPageState();
}

class _ComparacionPageState extends State<ComparacionPage> {
  final CsvService csvService = CsvService();
  final ComparadorService comparadorService = ComparadorService();

  List<Comparacion> lista = [];
  bool cargando = true;
  String filtro = "TODOS";

  int aumentos = 0;
  int bajas = 0;
  int nuevos = 0;
  int iguales = 0;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
    });
    lista = await comparadorService.obtenerComparacion();
    aumentos = await comparadorService.cantidadAumentos();
    bajas = await comparadorService.cantidadBajas();
    nuevos = await comparadorService.cantidadNuevos();
    iguales = await comparadorService.cantidadIguales();
    if (!mounted) return;
    setState(() {
      cargando = false;
    });
  }

  Future<void> analizarNuevaLista() async {
    setState(() {
      cargando = true;
    });
    await csvService.analizarArchivo();
    if (!mounted) return;
    await cargar();
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case "SUBIO":
        return Colors.red;
      case "BAJO":
        return Colors.green;
      case "NUEVO":
        return Colors.blue;
      case "IGUAL":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado) {
      case "SUBIO":
        return Icons.arrow_upward;
      case "BAJO":
        return Icons.arrow_downward;
      case "NUEVO":
        return Icons.fiber_new;
      case "IGUAL":
        return Icons.remove;
      default:
        return Icons.help;
    }
  }

  List<Comparacion> get listaFiltrada {
    if (filtro == "TODOS") {
      return lista;
    }
    return lista.where((e) => e.estado == filtro).toList();
  }

  Widget botonFiltro(String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: filtro == texto,
        selectedColor: color.withValues(alpha: .20),
        onSelected: (_) {
          setState(() {
            filtro = texto;
          });
        },
      ),
    );
  }

  Future<void> actualizarPrecios() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Actualizar base de precios'),
        content: Text(
          '¿Actualizar ${lista.length} productos? Esta acción actualizará los precios en la base de datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (ok != true) {
      return;
    }

    setState(() {
      cargando = true;
    });
    await comparadorService.actualizarProductos();
    await comparadorService.limpiarComparaciones();
    if (!mounted) return;
    setState(() {
      lista = [];
      aumentos = 0;
      bajas = 0;
      nuevos = 0;
      iguales = 0;
      cargando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Precios actualizados correctamente.")),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparación de Precios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: analizarNuevaLista,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: lista.isEmpty ? null : actualizarPrecios,
        icon: const Icon(Icons.save),
        label: const Text("ACTUALIZAR"),
      ),
      body: Column(
        children: [
          if (!cargando && lista.isNotEmpty) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _statChip("SUBIO", aumentos, Colors.red),
                  _statChip("BAJO", bajas, Colors.green),
                  _statChip("NUEVO", nuevos, Colors.blue),
                  _statChip("IGUAL", iguales, Colors.grey),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                botonFiltro("TODOS", Colors.black),
                botonFiltro("SUBIO", Colors.red),
                botonFiltro("BAJO", Colors.green),
                botonFiltro("NUEVO", Colors.blue),
                botonFiltro("IGUAL", Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : listaFiltrada.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay diferencias.",
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        itemCount: listaFiltrada.length,
                        itemBuilder: (context, index) {
                          final item = listaFiltrada[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorEstado(item.estado),
                                child: Icon(iconoEstado(item.estado),
                                    color: Colors.white),
                              ),
                              title: Text(
                                item.descripcion,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 120,
                                        child: Text("Código",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Expanded(child: Text(item.codigo)),
                                    ],
                                  ),
                                  if (item.marca.isNotEmpty)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 120,
                                          child: Text("Marca",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(child: Text(item.marca)),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 120,
                                        child: Text("Precio viejo",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Expanded(
                                          child: Text(
                                              "\$${item.precioViejo.toStringAsFixed(2)}")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 120,
                                        child: Text("Precio nuevo",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Expanded(
                                          child: Text(
                                              "\$${item.precioNuevo.toStringAsFixed(2)}")),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorEstado(item.estado)
                                          .withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.estado,
                                      style: TextStyle(
                                        color: colorEstado(item.estado),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.precioViejo == 0
                                          ? "-"
                                          : "${(((item.precioNuevo - item.precioViejo) / item.precioViejo) * 100).toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        color: colorEstado(item.estado),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
