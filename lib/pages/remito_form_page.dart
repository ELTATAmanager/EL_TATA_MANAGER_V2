import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cliente.dart';
import '../models/producto.dart';
import '../models/remito.dart';
import '../models/remito_detalle.dart';
import '../services/cliente_service.dart';
import '../services/pdf_service.dart';
import '../services/producto_service.dart';
import '../services/remito_service.dart';

class _ItemRemito {
  final Producto producto;
  int cantidad;
  double precioUnitario;

  _ItemRemito({
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}

class RemitoFormPage extends StatefulWidget {
  const RemitoFormPage({super.key});

  @override
  State<RemitoFormPage> createState() => _RemitoFormPageState();
}

class _RemitoFormPageState extends State<RemitoFormPage> {
  final RemitoService remitoService = RemitoService();
  final ClienteService clienteService = ClienteService();
  final ProductoService productoService = ProductoService();
  final PdfService pdfService = PdfService();

  final TextEditingController observacionesController =
      TextEditingController();
  final TextEditingController buscarProductoController =
      TextEditingController();

  List<Cliente> clientes = [];
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  List<_ItemRemito> items = [];

  Cliente? clienteSeleccionado;
  bool cargando = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    clientes = await clienteService.obtenerTodos();
    productos = await productoService.obtenerTodos();
    productosFiltrados = productos;
    if (!mounted) return;
    setState(() => cargando = false);
  }

  void filtrarProductos(String texto) {
    texto = texto.toLowerCase();
    productosFiltrados = productos
        .where((p) =>
            p.descripcion.toLowerCase().contains(texto) ||
            p.codigo.toLowerCase().contains(texto))
        .toList();
    setState(() {});
  }

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  void _agregarItemDirecto(
    Producto producto, {
    int cantidad = 1,
    double? precioUnitario,
  }) {
    final yaExiste = items.indexWhere((it) => it.producto.id == producto.id);
    if (yaExiste >= 0) {
      setState(() {
        items[yaExiste].cantidad += cantidad;
        if (precioUnitario != null) {
          items[yaExiste].precioUnitario = precioUnitario;
        }
      });
      return;
    }

    setState(() {
      items.add(
        _ItemRemito(
          producto: producto,
          cantidad: cantidad,
          precioUnitario: precioUnitario ?? producto.precio,
        ),
      );
    });
  }

  Future<void> agregarProducto() async {
    buscarProductoController.clear();
    productosFiltrados = productos;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, ctrl) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TextField(
                  controller: buscarProductoController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (v) {
                    filtrarProductos(v);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    itemCount: productosFiltrados.length,
                    itemBuilder: (_, i) {
                      final p = productosFiltrados[i];
                      final sinStock = p.stock <= 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(p.descripcion),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${p.codigo} | \$${p.precio.toStringAsFixed(2)} | Stock: ${p.stock}',
                              ),
                              if (sinStock)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sin stock disponible',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _agregarItemDirecto(p);
                            },
                            child: const Text('Agregar'),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pedirCantidad(p);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pedirCantidad(Producto producto) async {
    final cantidadCtrl = TextEditingController(text: '1');
    final precioCtrl =
        TextEditingController(text: producto.precio.toStringAsFixed(2));

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(producto.descripcion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadCtrl,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: precioCtrl,
              decoration: const InputDecoration(
                labelText: 'Precio unitario',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final cantidad = int.tryParse(cantidadCtrl.text) ?? 1;
      final precio =
          double.tryParse(precioCtrl.text.replaceAll(',', '.')) ?? producto.precio;
      _agregarItemDirecto(
        producto,
        cantidad: cantidad,
        precioUnitario: precio,
      );
    }
  }

  Future<void> _imprimirOCompartirRemito(
    Remito remito,
    List<RemitoDetalle> detalles,
    int remitoId,
  ) async {
    final remitoMap = {
      'id': remitoId,
      'numero': remito.numero,
      'fecha': remito.fecha.toIso8601String(),
      'total': remito.total,
    };
    final itemsPdf = detalles.map((detalle) {
      final producto = items.firstWhere((item) => item.producto.id == detalle.productoId).producto;
      return {
        'descripcion': producto.descripcion,
        'cantidad': detalle.cantidad,
        'precio': detalle.precioUnitario,
        'subtotal': detalle.subtotal,
      };
    }).toList();

    final accion = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remito guardado'),
        content: const Text('¿Querés imprimir o compartir el remito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cerrar'),
            child: const Text('Cerrar'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'imprimir'),
            icon: const Icon(Icons.print, color: Colors.orange),
            label: const Text('Imprimir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'compartir'),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
        ],
      ),
    );

    if (accion == null || accion == 'cerrar') {
      return;
    }

    final pdf = await pdfService.generateRemitoPdf(
      remitoMap,
      itemsPdf,
      clienteSeleccionado?.nombre ?? 'Sin cliente',
    );
    if (pdf.isEmpty) {
      return;
    }

    if (accion == 'imprimir') {
      await Printing.layoutPdf(onLayout: (_) async => pdf);
      return;
    }

    final archivo = await pdfService.guardarPdf(
      pdf,
      'remito_${remito.numero}.pdf',
    );
    await SharePlus.instance.share(
      ShareParams(files: [XFile(archivo.path)]),
    );
  }

  Future<void> guardar() async {
    if (clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un cliente')),
      );
      return;
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregá al menos un producto')),
      );
      return;
    }

    final hayStockInsuficiente = items.any(
      (item) => item.cantidad > item.producto.stock,
    );
    if (hayStockInsuficiente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hay productos con cantidad mayor al stock disponible. El remito se guardará igualmente.',
          ),
        ),
      );
    }

    setState(() => guardando = true);

    try {
      final numero = await remitoService.generarNumero();
      final remito = Remito(
        numero: numero,
        fecha: DateTime.now(),
        tipo: 'salida',
        clienteId: clienteSeleccionado!.id.toString(),
        estado: 'confirmado',
        observaciones: observacionesController.text.trim(),
        total: total,
      );

      final detalles = items
          .map((i) => RemitoDetalle(
                remitoId: 0,
                productoId: i.producto.id!,
                cantidad: i.cantidad,
                precioUnitario: i.precioUnitario,
                subtotal: i.subtotal,
              ))
          .toList();

      final remitoId = await remitoService.insertar(remito, detalles);

      if (!mounted) return;
      setState(() => guardando = false);
      await _imprimirOCompartirRemito(remito, detalles, remitoId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el remito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Remito'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<Cliente>(
                          value: clienteSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Cliente',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: clientes
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.nombre),
                                  ))
                              .toList(),
                          onChanged: (c) =>
                              setState(() => clienteSeleccionado = c),
                          hint: const Text('Seleccionar cliente'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Productos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              'Sin productos aún',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final stockInsuficiente =
                                item.cantidad > item.producto.stock;
                            return Card(
                              child: ListTile(
                                title: Text(item.producto.descripcion),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'x${item.cantidad} × \$${item.precioUnitario.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'Stock disponible: ${item.producto.stock}',
                                      style: TextStyle(
                                        color: stockInsuficiente
                                            ? Colors.red
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${item.subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () {
                                        setState(() => items.removeAt(idx));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar producto'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: guardando ? null : guardar,
                        icon: guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('GUARDAR'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
