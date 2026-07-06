import 'package:flutter/material.dart';

import '../services/remito_service.dart';
import 'remito_form_page.dart';

class RemitosPage extends StatefulWidget {
  const RemitosPage({super.key});

  @override
  State<RemitosPage> createState() => _RemitosPageState();
}

class _RemitosPageState extends State<RemitosPage> {
  final RemitoService service = RemitoService();

  List<Map<String, dynamic>> remitos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);
    remitos = await service.obtenerTodosConCliente();
    if (!mounted) return;
    setState(() => cargando = false);
  }

  Future<void> verItems(Map<String, dynamic> remito) async {
    final items = await service.obtenerItems(remito['id']);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Remito ${remito['numero']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Sin ítems"))
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          title: Text(item['descripcion'] ?? ''),
                          subtitle: Text(
                            "Código: ${item['codigo']}  |  Marca: ${item['marca'] ?? '-'}",
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("x${item['cantidad']}"),
                              Text(
                                "\$${(item['subtotal'] as num).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "\$${(remito['total'] as num).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmarAnular(Map<String, dynamic> remito) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Anular remito"),
        content: Text("¿Anular el remito ${remito['numero']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text("Anular", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await service.anular(remito['id']);
      cargar();
    }
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'confirmado':
        return Colors.green;
      case 'anulado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remitos"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RemitoFormPage()),
          );
          cargar();
        },
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : remitos.isEmpty
              ? const Center(
                  child: Text(
                    "No hay remitos.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: remitos.length,
                  itemBuilder: (context, i) {
                    final r = remitos[i];
                    final estado = r['estado'] ?? 'pendiente';
                    final fecha =
                        DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now();
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        onTap: () => verItems(r),
                        leading: CircleAvatar(
                          backgroundColor:
                              colorEstado(estado).withValues(alpha: .15),
                          child: Icon(
                            Icons.receipt,
                            color: colorEstado(estado),
                          ),
                        ),
                        title: Text(
                          r['numero'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['clienteNombre'] ?? 'Sin cliente'),
                            Text(
                              "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${(r['total'] as num).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    colorEstado(estado).withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                estado.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorEstado(estado),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
