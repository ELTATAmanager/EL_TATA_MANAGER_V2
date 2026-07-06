import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../services/pdf_service.dart';
import '../services/remito_service.dart';
import 'remito_form_page.dart';

class RemitosPage extends StatefulWidget {
  const RemitosPage({super.key});

  @override
  State<RemitosPage> createState() => _RemitosPageState();
}

class _RemitosPageState extends State<RemitosPage> {
  final RemitoService service = RemitoService();
  final PdfService pdfService = PdfService();

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

  String formatearFecha(String? texto) {
    final fecha = DateTime.tryParse(texto ?? '') ?? DateTime.now();
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
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
                    'Remito ${remito['numero']}',
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
                  ? const Center(child: Text('Sin ítems'))
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          title: Text(item['descripcion'] ?? ''),
                          subtitle: Text(
                            'Código: ${item['codigo']}  |  Marca: ${item['marca'] ?? '-'}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('x${item['cantidad']}'),
                              Text(
                                '\$${(item['subtotal'] as num).toStringAsFixed(2)}',
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
                    'TOTAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${(remito['total'] as num).toStringAsFixed(2)}',
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

  Future<List<dynamic>> _obtenerPdfItems(Map<String, dynamic> remito) {
    return service.obtenerItems(remito['id']);
  }

  Future<void> imprimirRemito(Map<String, dynamic> remito) async {
    final items = await _obtenerPdfItems(remito);
    final pdf = await pdfService.generateRemitoPdf(
      remito,
      items,
      remito['clienteNombre']?.toString() ?? 'Sin cliente',
    );
    if (pdf.isEmpty) return;
    await Printing.layoutPdf(onLayout: (_) async => pdf);
  }

  Future<void> compartirRemito(Map<String, dynamic> remito) async {
    final items = await _obtenerPdfItems(remito);
    final pdf = await pdfService.generateRemitoPdf(
      remito,
      items,
      remito['clienteNombre']?.toString() ?? 'Sin cliente',
    );
    if (pdf.isEmpty) return;
    final archivo = await pdfService.guardarPdf(
      pdf,
      'remito_${remito['numero']}.pdf',
    );
    await SharePlus.instance.share(
      ShareParams(files: [XFile(archivo.path)]),
    );
  }

  Future<void> confirmarAnular(Map<String, dynamic> remito) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Anular remito'),
        content: Text('¿Anular el remito ${remito['numero']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Anular', style: TextStyle(color: Colors.orange)),
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

  Widget estadoChip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorEstado(estado).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: colorEstado(estado),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remitos'),
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
                    'No hay remitos.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: remitos.length,
                  itemBuilder: (context, i) {
                    final remito = remitos[i];
                    final estado = remito['estado'] ?? 'pendiente';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => verItems(remito),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        colorEstado(estado).withValues(alpha: .15),
                                    child: Icon(
                                      Icons.receipt,
                                      color: colorEstado(estado),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          remito['numero'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(remito['clienteNombre'] ?? 'Sin cliente'),
                                        Text(
                                          formatearFecha(remito['fecha']?.toString()),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${((remito['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      estadoChip(estado),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: 'Imprimir PDF',
                                    onPressed: () => imprimirRemito(remito),
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Compartir PDF',
                                    onPressed: () => compartirRemito(remito),
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Anular remito',
                                    onPressed: estado == 'anulado'
                                        ? null
                                        : () => confirmarAnular(remito),
                                    icon: Icon(
                                      Icons.cancel,
                                      color: estado == 'anulado'
                                          ? Colors.grey
                                          : Colors.red,
                                    ),
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
    );
  }
}
