import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/cliente_service.dart';
import '../services/csv_service.dart';
import '../services/pdf_service.dart';
import '../services/producto_service.dart';
import '../services/proveedor_service.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final ProductoService productoService = ProductoService();
  final ClienteService clienteService = ClienteService();
  final ProveedorService proveedorService = ProveedorService();
  final PdfService pdfService = PdfService();
  final CsvService csvService = CsvService();

  bool generando = false;

  Future<void> _compartirArchivo(String path) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() => generando = true);
    try {
      await accion();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el reporte: $e')),
      );
    } finally {
      if (mounted) setState(() => generando = false);
    }
  }

  Future<void> _exportarProductosPdf() => _ejecutar(() async {
        final productos = await productoService.obtenerTodos();
        final filas = productos
            .map((p) => [
                  p.codigo,
                  p.descripcion,
                  p.marca,
                  p.categoria,
                  p.stock.toString(),
                  '\$${p.costo.toStringAsFixed(2)}',
                  '\$${p.precio.toStringAsFixed(2)}',
                ])
            .toList();
        final pdf = await pdfService.generateListPdf(
          titulo: 'LISTA DE PRODUCTOS',
          headers: const [
            'Código',
            'Descripción',
            'Marca',
            'Categoría',
            'Stock',
            'Costo',
            'Precio',
          ],
          filas: filas,
        );
        final archivo =
            await pdfService.guardarPdfReporte(pdf, 'productos.pdf');
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarProductosCsv() => _ejecutar(() async {
        final productos = await productoService.obtenerTodos();
        final filas = productos
            .map((p) => [
                  p.codigo,
                  p.descripcion,
                  p.marca,
                  p.categoria,
                  p.stock,
                  p.costo,
                  p.precio,
                ])
            .toList();
        final archivo = await csvService.exportarCsv(
          'productos.csv',
          const [
            'Código',
            'Descripción',
            'Marca',
            'Categoría',
            'Stock',
            'Costo',
            'Precio',
          ],
          filas,
        );
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarClientesPdf() => _ejecutar(() async {
        final clientes = await clienteService.obtenerTodos();
        final filas = clientes
            .map((c) => [
                  c.nombreCompleto,
                  c.telefono,
                  c.email,
                  c.direccion,
                  c.localidad,
                ])
            .toList();
        final pdf = await pdfService.generateListPdf(
          titulo: 'LISTA DE CLIENTES',
          headers: const [
            'Nombre',
            'Teléfono',
            'Email',
            'Dirección',
            'Localidad',
          ],
          filas: filas,
        );
        final archivo = await pdfService.guardarPdfReporte(pdf, 'clientes.pdf');
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarClientesCsv() => _ejecutar(() async {
        final clientes = await clienteService.obtenerTodos();
        final filas = clientes
            .map((c) => [
                  c.nombreCompleto,
                  c.telefono,
                  c.email,
                  c.direccion,
                  c.localidad,
                  c.saldo,
                ])
            .toList();
        final archivo = await csvService.exportarCsv(
          'clientes.csv',
          const [
            'Nombre',
            'Teléfono',
            'Email',
            'Dirección',
            'Localidad',
            'Saldo',
          ],
          filas,
        );
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarProveedoresPdf() => _ejecutar(() async {
        final proveedores = await proveedorService.obtenerTodos();
        final filas = proveedores
            .map((p) => [
                  p.nombre,
                  p.contacto,
                  p.telefono,
                  p.email,
                  p.condicionesComerciales,
                ])
            .toList();
        final pdf = await pdfService.generateListPdf(
          titulo: 'LISTA DE PROVEEDORES',
          headers: const [
            'Nombre',
            'Contacto',
            'Teléfono',
            'Email',
            'Condiciones',
          ],
          filas: filas,
        );
        final archivo =
            await pdfService.guardarPdfReporte(pdf, 'proveedores.pdf');
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarProveedoresCsv() => _ejecutar(() async {
        final proveedores = await proveedorService.obtenerTodos();
        final filas = proveedores
            .map((p) => [
                  p.nombre,
                  p.contacto,
                  p.telefono,
                  p.email,
                  p.condicionesComerciales,
                ])
            .toList();
        final archivo = await csvService.exportarCsv(
          'proveedores.csv',
          const [
            'Nombre',
            'Contacto',
            'Teléfono',
            'Email',
            'Condiciones',
          ],
          filas,
        );
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarInventarioPdf() => _ejecutar(() async {
        final productos = await productoService.obtenerTodos();
        final filas = productos
            .map((p) => [
                  p.codigo,
                  p.descripcion,
                  p.stock.toString(),
                  '\$${p.costo.toStringAsFixed(2)}',
                  '\$${(p.costo * p.stock).toStringAsFixed(2)}',
                ])
            .toList();
        final valorTotal = productos.fold<double>(
          0,
          (sum, p) => sum + p.costo * p.stock,
        );
        filas.add([
          '',
          'VALOR TOTAL DE INVENTARIO',
          '',
          '',
          '\$${valorTotal.toStringAsFixed(2)}',
        ]);
        final pdf = await pdfService.generateListPdf(
          titulo: 'INVENTARIO CON VALOR',
          headers: const [
            'Código',
            'Descripción',
            'Stock',
            'Costo unit.',
            'Valor total',
          ],
          filas: filas,
        );
        final archivo =
            await pdfService.guardarPdfReporte(pdf, 'inventario_valor.pdf');
        await _compartirArchivo(archivo.path);
      });

  Future<void> _exportarInventarioCsv() => _ejecutar(() async {
        final productos = await productoService.obtenerTodos();
        final filas = productos
            .map((p) => [
                  p.codigo,
                  p.descripcion,
                  p.stock,
                  p.costo,
                  p.costo * p.stock,
                ])
            .toList();
        final archivo = await csvService.exportarCsv(
          'inventario_valor.csv',
          const ['Código', 'Descripción', 'Stock', 'Costo unit.', 'Valor total'],
          filas,
        );
        await _compartirArchivo(archivo.path);
      });

  Widget _tarjetaReporte({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required VoidCallback onPdf,
    required VoidCallback onCsv,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: generando ? null : onPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: generando ? null : onCsv,
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('CSV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Reportes',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Generá y compartí reportes en PDF o CSV.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _tarjetaReporte(
                icon: Icons.inventory_2_rounded,
                titulo: 'Lista de productos',
                descripcion: 'Código, descripción, marca, stock y precios',
                onPdf: _exportarProductosPdf,
                onCsv: _exportarProductosCsv,
              ),
              _tarjetaReporte(
                icon: Icons.groups_rounded,
                titulo: 'Lista de clientes',
                descripcion: 'Datos de contacto y saldo',
                onPdf: _exportarClientesPdf,
                onCsv: _exportarClientesCsv,
              ),
              _tarjetaReporte(
                icon: Icons.local_shipping_rounded,
                titulo: 'Lista de proveedores',
                descripcion: 'Datos de contacto y condiciones comerciales',
                onPdf: _exportarProveedoresPdf,
                onCsv: _exportarProveedoresCsv,
              ),
              _tarjetaReporte(
                icon: Icons.warehouse_rounded,
                titulo: 'Inventario con valor',
                descripcion: 'Stock valorizado a costo por producto',
                onPdf: _exportarInventarioPdf,
                onCsv: _exportarInventarioCsv,
              ),
            ],
          ),
          if (generando)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
