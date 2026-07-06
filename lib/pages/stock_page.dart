import 'package:flutter/material.dart';

import '../models/movimiento_stock.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../services/stock_service.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final StockService stockService = StockService();
  final ProductoService productoService = ProductoService();
  final TextEditingController buscarController = TextEditingController();

  List<Map<String, dynamic>> movimientos = [];
  List<Producto> productos = [];
  List<Producto> alertas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);
    movimientos = await stockService.obtenerMovimientos();
    productos = await productoService.obtenerTodos();
    alertas = await stockService.obtenerProductosConStockBajo();
    if (!mounted) return;
    setState(() => cargando = false);
  }

  List<Map<String, dynamic>> get movimientosFiltrados {
    final texto = buscarController.text.trim().toLowerCase();
    if (texto.isEmpty) {
      return movimientos;
    }

    return movimientos.where((movimiento) {
      return (movimiento['productoNombre']?.toString().toLowerCase() ?? '')
              .contains(texto) ||
          (movimiento['productoCodigo']?.toString().toLowerCase() ?? '')
              .contains(texto) ||
          (movimiento['tipo']?.toString().toLowerCase() ?? '').contains(texto) ||
          (movimiento['motivo']?.toString().toLowerCase() ?? '').contains(texto);
    }).toList();
  }

  String formatearFecha(String? texto) {
    final fecha = DateTime.tryParse(texto ?? '') ?? DateTime.now();
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} $hora';
  }

  Color colorTipo(String tipo) {
    switch (tipo) {
      case 'entrada':
        return Colors.green;
      case 'salida':
      case 'reversion':
        return Colors.red;
      case 'ajuste':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> registrarMovimiento({Producto? productoInicial}) async {
    Producto? productoSeleccionado = productoInicial;
    String tipo = productoInicial != null ? 'entrada' : 'entrada';
    final cantidadController = TextEditingController(text: '1');
    final motivoController = TextEditingController(
      text: productoInicial != null ? 'Reposición de stock' : '',
    );

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Registrar movimiento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                    DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => tipo = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Producto>(
                  value: productoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(),
                  ),
                  items: productos
                      .map(
                        (producto) => DropdownMenuItem(
                          value: producto,
                          child: Text(producto.descripcion),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => productoSeleccionado = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true || productoSeleccionado == null) {
      return;
    }

    final cantidad = int.tryParse(cantidadController.text) ?? 0;
    if (cantidad <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá una cantidad válida.')),
      );
      return;
    }

    await stockService.registrarMovimiento(
      MovimientoStock(
        productoId: productoSeleccionado!.id!,
        tipo: tipo,
        cantidad: cantidad,
        fecha: DateTime.now(),
        motivo: motivoController.text.trim().isEmpty
            ? 'Movimiento manual'
            : motivoController.text.trim(),
      ),
    );

    if (!mounted) return;
    await cargar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento registrado correctamente.')),
    );
  }

  Widget chipTipo(String tipo) {
    final color = colorTipo(tipo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tipo.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock'),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'Movimientos'),
              Tab(text: 'Alertas'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => registrarMovimiento(),
          child: const Icon(Icons.add),
        ),
        body: cargando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: buscarController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Buscar movimiento...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: movimientosFiltrados.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay movimientos registrados.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                itemCount: movimientosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final movimiento = movimientosFiltrados[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: colorTipo(
                                          movimiento['tipo'] ?? '',
                                        ).withValues(alpha: .15),
                                        child: Icon(
                                          Icons.swap_vert,
                                          color: colorTipo(
                                            movimiento['tipo'] ?? '',
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        movimiento['productoNombre'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          chipTipo(movimiento['tipo'] ?? ''),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Cantidad: ${movimiento['cantidad']}  |  ${formatearFecha(movimiento['fecha']?.toString())}',
                                          ),
                                          if ((movimiento['motivo'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            Text('Motivo: ${movimiento['motivo']}'),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  alertas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay alertas de stock bajo.',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: alertas.length,
                          itemBuilder: (context, index) {
                            final producto = alertas[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.withValues(
                                    alpha: .15,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  producto.descripcion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Stock actual: ${producto.stock}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                trailing: TextButton.icon(
                                  onPressed: () => registrarMovimiento(
                                    productoInicial: producto,
                                  ),
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.orange),
                                  label: const Text('Entrada'),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}
