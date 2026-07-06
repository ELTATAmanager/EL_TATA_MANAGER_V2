import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import '../theme/app_visuals.dart';
import 'producto_form_page.dart';
import 'scanner_page.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  static const int _stockNivelAlto = 10;

  final ProductoService service = ProductoService();
  final TextEditingController buscarController = TextEditingController();

  List<Producto> productos = [];
  List<Producto> filtrados = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarProductos() async {
    productos = await service.obtenerTodos();
    filtrados = productos;

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  void buscar(String texto) {
    final query = texto.toLowerCase();

    filtrados = productos.where((p) {
      return p.descripcion.toLowerCase().contains(query) ||
          p.codigo.toLowerCase().contains(query) ||
          p.marca.toLowerCase().contains(query) ||
          p.categoria.toLowerCase().contains(query);
    }).toList();

    setState(() {});
  }

  Future<void> _escanearCodigo() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );

    if (codigo == null || codigo.trim().isEmpty || !mounted) return;

    buscarController.text = codigo;
    buscar(codigo);
  }

  Future<void> eliminar(Producto producto) async {
    if (producto.id == null) return;

    await service.eliminar(producto.id!);
    await cargarProductos();
  }

  Color _stockColor(int stock) {
    final colorScheme = Theme.of(context).colorScheme;

    if (stock > _stockNivelAlto) return AppVisuals.success(colorScheme);
    if (stock > 0) return AppVisuals.warning(colorScheme);
    return AppVisuals.danger(colorScheme);
  }

  String _lineaPrecios(Producto producto) {
    final partes = ['L1: \$${producto.precio.toStringAsFixed(2)}'];
    if (producto.precio2 > 0) {
      partes.add('L2: \$${producto.precio2.toStringAsFixed(2)}');
    }
    if (producto.precio3 > 0) {
      partes.add('L3: \$${producto.precio3.toStringAsFixed(2)}');
    }
    return partes.join(' | ');
  }

  Future<void> _editarProducto(Producto producto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoFormPage(producto: producto),
      ),
    );

    await cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
        actions: [
          IconButton(
            onPressed: _escanearCodigo,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear código',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductoFormPage(),
            ),
          );

          await cargarProductos();
        },
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: buscarController,
                    onChanged: buscar,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Buscar producto...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final p = filtrados[index];
                      final stockColor = _stockColor(p.stock);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.inventory_2_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            p.descripcion,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${p.codigo} | ${p.marca} | ${p.categoria}'),
                              const SizedBox(height: 2),
                              Text(_lineaPrecios(p)),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Stock: ${p.stock}',
                                    style: TextStyle(
                                      color: stockColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: colorScheme.primary,
                                      ),
                                      onPressed: () => _editarProducto(p),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        Icons.delete_rounded,
                                        color: AppVisuals.danger(colorScheme),
                                      ),
                                      onPressed: () => eliminar(p),
                                    ),
                                  ],
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
