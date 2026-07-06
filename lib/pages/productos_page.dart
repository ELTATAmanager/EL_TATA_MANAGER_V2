import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import 'producto_form_page.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductoService service = ProductoService();

  final TextEditingController buscarController =
      TextEditingController();

  List<Producto> productos = [];
  List<Producto> filtrados = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
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
    texto = texto.toLowerCase();

    filtrados = productos.where((p) {
      return p.descripcion.toLowerCase().contains(texto) ||
          p.codigo.toLowerCase().contains(texto) ||
          p.marca.toLowerCase().contains(texto);
    }).toList();

    setState(() {});
  }

  Future<void> eliminar(Producto producto) async {
    if (producto.id == null) return;

    await service.eliminar(producto.id!);

    cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
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

          cargarProductos();
        },
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
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

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            child: const Icon(Icons.inventory),
                          ),
                          title: Text(
                            p.descripcion,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text("Código: ${p.codigo}"),
                              Text("Marca: ${p.marca}"),
                              Text("Stock: ${p.stock}"),
                              Text(
                                  "Precio: \$${p.precio.toStringAsFixed(2)}"),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text("Editar"),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                child: Text("Eliminar"),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 1) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductoFormPage(
                                      producto: p,
                                    ),
                                  ),
                                );

                                cargarProductos();
                              }

                              if (value == 2) {
                                eliminar(p);
                              }
                            },
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