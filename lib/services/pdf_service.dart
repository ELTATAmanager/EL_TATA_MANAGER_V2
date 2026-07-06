import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  String _formatearFecha(String? fechaTexto) {
    final fecha = DateTime.tryParse(fechaTexto ?? '') ?? DateTime.now();
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  double _resolverPrecio(Map<String, dynamic> item) {
    final precio = item['precioUnitario'] ?? item['precio'];
    return (precio as num?)?.toDouble() ?? 0;
  }

  Uint8List _bytesVacios() => Uint8List(0);

  Future<Uint8List> generateRemitoPdf(
    Map<String, dynamic> remito,
    List items,
    String clienteNombre,
  ) async {
    if (items.isEmpty) {
      return _bytesVacios();
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.orange),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EL TATA Manager',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Remito de venta'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Remito ${remito['numero'] ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Fecha: ${_formatearFecha(remito['fecha']?.toString())}'),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cliente',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(clienteNombre.isEmpty ? 'Sin cliente' : clienteNombre),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            border: null,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.orange100),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
            headers: const ['Producto', 'Cant.', 'P. Unit.', 'Subtotal'],
            data: items.map<List<String>>((item) {
              final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0;
              return [
                item['descripcion']?.toString() ?? '',
                '${item['cantidad'] ?? 0}',
                '\$${_resolverPrecio(item).toStringAsFixed(2)}',
                '\$${subtotal.toStringAsFixed(2)}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.orange),
              ),
              child: pw.Text(
                'TOTAL: \$${((remito['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<File> guardarPdf(Uint8List bytes, String nombreArchivo) async {
    final directorio = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(directorio.path, 'remitos'));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final archivo = File(p.join(carpeta.path, nombreArchivo));
    return archivo.writeAsBytes(bytes, flush: true);
  }
}
