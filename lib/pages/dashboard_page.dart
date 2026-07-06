import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/cliente_service.dart';
import '../services/producto_service.dart';
import '../services/remito_service.dart';
import '../theme/app_visuals.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProductoService productoService = ProductoService();
  final ClienteService clienteService = ClienteService();
  final RemitoService remitoService = RemitoService();

  int totalProductos = 0;
  int totalClientes = 0;
  int totalRemitos = 0;
  double totalVentas = 0;
  double valorStock = 0;
  List<Map<String, dynamic>> productosTop = [];
  List<Map<String, dynamic>> clientesTop = [];
  List<Producto> sinStock = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);

    final productos = await productoService.obtenerTodos();
    final clientes = await clienteService.obtenerTodos();
    final remitos = await remitoService.cantidad();
    final ventas = await remitoService.totalVentas();
    final topProductos = await remitoService.topProductos();
    final topClientes = await remitoService.topClientes();

    double stock = 0;
    List<Producto> bajo = [];
    for (final p in productos) {
      stock += p.precio * p.stock;
      if (p.stock == 0) bajo.add(p);
    }

    if (!mounted) return;
    setState(() {
      totalProductos = productos.length;
      totalClientes = clientes.length;
      totalRemitos = remitos;
      totalVentas = ventas;
      valorStock = stock;
      productosTop = topProductos;
      clientesTop = topClientes;
      sinStock = bajo.take(5).toList();
      cargando = false;
    });
  }

  Widget _statCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: .15),
                  radius: 20,
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankingCard({
    required String titulo,
    required String subtitulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(icono, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productosColor = AppVisuals.primaryAccent(colorScheme);
    final clientesColor = AppVisuals.secondaryAccent(colorScheme);
    final remitosColor = AppVisuals.info(colorScheme);
    final ventasColor = AppVisuals.success(colorScheme);
    final stockColor = AppVisuals.warning(colorScheme);
    final topProductosColor = AppVisuals.tertiaryAccent(colorScheme);
    final topClientesColor = AppVisuals.info(colorScheme);
    final sinStockColor = AppVisuals.danger(colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargar,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Resumen general",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _statCard(
                        titulo: "Productos",
                        valor: "$totalProductos",
                        icono: Icons.inventory_2_rounded,
                        color: productosColor,
                      ),
                      _statCard(
                        titulo: "Clientes",
                        valor: "$totalClientes",
                        icono: Icons.groups_rounded,
                        color: clientesColor,
                      ),
                      _statCard(
                        titulo: "Remitos",
                        valor: "$totalRemitos",
                        icono: Icons.description_rounded,
                        color: remitosColor,
                      ),
                      _statCard(
                        titulo: "Total ventas",
                        valor: "\$${totalVentas.toStringAsFixed(0)}",
                        icono: Icons.payments_rounded,
                        color: ventasColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: stockColor.withValues(alpha: .15),
                        child: Icon(Icons.warehouse_rounded, color: stockColor),
                      ),
                      title: const Text("Valor del stock"),
                      subtitle: const Text("Precio de venta × cantidad"),
                      trailing: Text(
                        "\$${valorStock.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: stockColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Top 5 productos más vendidos",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (productosTop.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('Sin ventas registradas'),
                      ),
                    )
                  else
                    ...productosTop.map(
                      (producto) => _rankingCard(
                        titulo: (producto['descripcion'] ?? 'Sin descripción')
                            .toString(),
                        subtitulo:
                            '${((producto['totalVendido'] as num?)?.toInt() ?? 0)} unidades vendidas',
                        valor:
                            '\$${((producto['totalMonto'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                        icono: Icons.sell_rounded,
                        color: topProductosColor,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    "Top 5 clientes",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (clientesTop.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('Sin clientes con compras'),
                      ),
                    )
                  else
                    ...clientesTop.map(
                      (cliente) => _rankingCard(
                        titulo: (cliente['nombre'] ?? 'Sin nombre').toString(),
                        subtitulo:
                            '${((cliente['cantidadRemitos'] as num?)?.toInt() ?? 0)} remitos',
                        valor:
                            '\$${((cliente['totalCompras'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                        icono: Icons.workspace_premium_rounded,
                        color: topClientesColor,
                      ),
                    ),
                  if (sinStock.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Productos sin stock",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sinStock.map(
                      (p) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: sinStockColor.withValues(alpha: .15),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: sinStockColor,
                            ),
                          ),
                          title: Text(p.descripcion),
                          subtitle: Text(p.codigo),
                          trailing: Text(
                            "SIN STOCK",
                            style: TextStyle(
                              color: sinStockColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
