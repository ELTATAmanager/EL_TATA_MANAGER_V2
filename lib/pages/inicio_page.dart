import 'package:flutter/material.dart';

import '../services/branding_service.dart';
import '../services/csv_service.dart';
import '../theme/app_visuals.dart';
import 'backup_page.dart';
import 'clientes_page.dart';
import 'comparacion_page.dart';
import 'configuracion_page.dart';
import 'dashboard_page.dart';
import 'productos_page.dart';
import 'proveedores_page.dart';
import 'remitos_page.dart';
import 'stock_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final CsvService csvService = CsvService();

  bool cargando = false;
  int selectedSidebar = 1;
  int selectedBottom = 0;

  Future<void> analizar() async {
    setState(() => cargando = true);

    try {
      final cantidad = await csvService.analizarArchivo();
      if (!mounted) return;
      setState(() => cargando = false);

      if (cantidad == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ningún archivo.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ComparacionPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _abrirPagina(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _onSidebarTap(int index) {
    setState(() => selectedSidebar = index);

    switch (index) {
      case 0:
        break;
      case 1:
        _abrirPagina(const ProductosPage());
        break;
      case 2:
        _abrirPagina(const ProveedoresPage());
        break;
      case 3:
        _abrirPagina(const RemitosPage());
        break;
      case 4:
        _abrirPagina(const StockPage());
        break;
      case 5:
        _abrirPagina(const DashboardPage());
        break;
      case 6:
        _abrirPagina(const BackupPage());
        break;
      case 7:
        _abrirPagina(const ConfiguracionPage());
        break;
      case 8:
        _abrirPagina(const ClientesPage());
        break;
      default:
        break;
    }
  }

  void _onBottomTap(int index) {
    setState(() => selectedBottom = index);

    switch (index) {
      case 0:
        break;
      case 1:
        _abrirPagina(const ProductosPage());
        break;
      case 2:
        _abrirPagina(const RemitosPage());
        break;
      case 3:
        _abrirPagina(const ConfiguracionPage());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1100;

        return Scaffold(
          backgroundColor: const Color(0xFF07090F),
          appBar: desktop ? null : _buildMobileAppBar(),
          body: desktop ? _buildDesktopLayout() : _buildMobileLayout(),
          bottomNavigationBar: desktop ? null : _buildMobileBottomBar(),
          floatingActionButton: desktop
              ? null
              : FloatingActionButton(
                  onPressed: cargando ? null : analizar,
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  child: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0C111A),
      title: const Text(
        'EL TATA MANAGER',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _DesktopTopHeader(title: BrandingService.instance.nombre),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                _DesktopSidebar(
                  selectedIndex: selectedSidebar,
                  onTap: _onSidebarTap,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DesktopWorkspace(
                    onAnalyze: analizar,
                    loading: cargando,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon:
                            Icon(Icons.search_rounded, color: Colors.white70),
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141A25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppVisuals.info(colorScheme),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.75,
              children: [
                _MobileKpiCard(
                  title: 'Productos',
                  value: '2.458',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                _MobileKpiCard(
                  title: 'Stock total',
                  value: '15.768',
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF22C55E),
                ),
                _MobileKpiCard(
                  title: 'Valor de stock',
                  value: '\$45.678.900',
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _MobileKpiCard(
                  title: 'Sin stock',
                  value: '128',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C111A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Productos recientes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _abrirPagina(const ProductosPage()),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  Expanded(
                    child: ListView(
                      children: const [
                        _MobileProductTile(
                          code: '3020',
                          name: 'Suela Profeta Negra',
                          stock: '15',
                          price: '\$ 18.500',
                        ),
                        _MobileProductTile(
                          code: '3050',
                          name: 'Suela Profeta Marrón',
                          stock: '23',
                          price: '\$ 19.200',
                        ),
                        _MobileProductTile(
                          code: 'WA01',
                          name: 'Wass Cordón Redondo',
                          stock: '120',
                          price: '\$ 1.250',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar() {
    return BottomAppBar(
      color: const Color(0xFF0C111A),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              selected: selectedBottom == 0,
              onTap: () => _onBottomTap(0),
            ),
            _BottomItem(
              icon: Icons.inventory_2_rounded,
              label: 'Productos',
              selected: selectedBottom == 1,
              onTap: () => _onBottomTap(1),
            ),
            const SizedBox(width: 24),
            _BottomItem(
              icon: Icons.point_of_sale_rounded,
              label: 'Ventas',
              selected: selectedBottom == 2,
              onTap: () => _onBottomTap(2),
            ),
            _BottomItem(
              icon: Icons.more_horiz_rounded,
              label: 'Más',
              selected: selectedBottom == 3,
              onTap: () => _onBottomTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTopHeader extends StatelessWidget {
  final String title;

  const _DesktopTopHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF02050A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Container(
            width: 124,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF7A00), width: 1.2),
            ),
            child: const Center(
              child: Text(
                'EL TATA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'EL TATA ',
                      style: TextStyle(
                        color: Color(0xFFFF7A00),
                        fontWeight: FontWeight.w900,
                        fontSize: 42,
                      ),
                    ),
                    TextSpan(
                      text: title.replaceAll('EL TATA ', ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 42,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Gestión de stock, ventas y mucho más',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
          const Spacer(),
          const _PlatformChip(icon: Icons.window_rounded, text: 'Windows'),
          const SizedBox(width: 10),
          const _PlatformChip(icon: Icons.android_rounded, text: 'Android'),
          const SizedBox(width: 10),
          const _PlatformChip(
            icon: Icons.cloud_done_rounded,
            text: 'Sincronizado\ncon Firebase',
            multiline: true,
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool multiline;

  const _PlatformChip({
    required this.icon,
    required this.text,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          textAlign: multiline ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.inventory_2_rounded, 'Productos'),
      (Icons.local_shipping_rounded, 'Proveedores'),
      (Icons.shopping_cart_rounded, 'Compras'),
      (Icons.point_of_sale_rounded, 'Ventas'),
      (Icons.warehouse_rounded, 'Stock'),
      (Icons.bar_chart_rounded, 'Reportes'),
      (Icons.settings_rounded, 'Configuración'),
      (Icons.groups_rounded, 'Clientes'),
    ];

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF0B111C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            height: 84,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF0F1724),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text(
                'EL TATA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        selected ? const Color(0xFFFF7A00) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      item.$1,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      item.$2,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => onTap(index),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text('M'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mati Arcuri\nAdministrador',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Icon(Icons.expand_more, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopWorkspace extends StatelessWidget {
  final VoidCallback onAnalyze;
  final bool loading;

  const _DesktopWorkspace({
    required this.onAnalyze,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Productos',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const SizedBox(
                width: 340,
                height: 42,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Filtros'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                ),
                onPressed: loading ? null : onAnalyze,
                icon: loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: const Text('Nuevo Producto'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.3,
            children: const [
              _DesktopKpiCard(
                title: 'Total productos',
                value: '2.458',
                icon: Icons.inventory_2_rounded,
                color: Color(0xFF8B5CF6),
              ),
              _DesktopKpiCard(
                title: 'Stock total',
                value: '15.768',
                icon: Icons.layers_rounded,
                color: Color(0xFF22C55E),
              ),
              _DesktopKpiCard(
                title: 'Valor de stock',
                value: '\$ 45.678.900',
                icon: Icons.attach_money_rounded,
                color: Color(0xFF3B82F6),
              ),
              _DesktopKpiCard(
                title: 'Productos sin stock',
                value: '128',
                icon: Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  const Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(8),
                      child: DataTable(
                        headingRowHeight: 44,
                        dataRowMinHeight: 48,
                        columns: [
                          DataColumn(label: Text('Código')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('Marca')),
                          DataColumn(label: Text('Categoría')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Precio Lista 1')),
                          DataColumn(label: Text('Ubicación')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('3020')),
                            DataCell(Text('Suela Profeta Negra')),
                            DataCell(Text('Profeta')),
                            DataCell(Text('Suelas')),
                            DataCell(Text('15')),
                            DataCell(Text('\$ 18.500')),
                            DataCell(Text('A-02-04-B')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('3050')),
                            DataCell(Text('Suela Profeta Marrón')),
                            DataCell(Text('Profeta')),
                            DataCell(Text('Suelas')),
                            DataCell(Text('23')),
                            DataCell(Text('\$ 19.200')),
                            DataCell(Text('A-02-05-A')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('WA01')),
                            DataCell(Text('Wass Cordón Redondo')),
                            DataCell(Text('Wass')),
                            DataCell(Text('Cordones')),
                            DataCell(Text('120')),
                            DataCell(Text('\$ 1.250')),
                            DataCell(Text('B-01-03-C')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('TP286-750')),
                            DataCell(Text('Tapper TR286 750gr')),
                            DataCell(Text('Tapper')),
                            DataCell(Text('Adhesivos')),
                            DataCell(Text('8')),
                            DataCell(Text('\$ 9.800')),
                            DataCell(Text('C-01-02-A')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.black12)),
                    ),
                    child: const Row(
                      children: [
                        Text('Mostrando 1 a 7 de 2.458 productos'),
                        Spacer(),
                        Text('1   2   3   4   5   ...   351'),
                        SizedBox(width: 20),
                        Text('7 por página'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DesktopKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 17,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MobileKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
}

class _MobileProductTile extends StatelessWidget {
  final String code;
  final String name;
  final String stock;
  final String price;

  const _MobileProductTile({
    required this.code,
    required this.name,
    required this.stock,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.checkroom_rounded, color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(color: Colors.white)),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Stock: $stock',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFFF7A00),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFFF7A00) : Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFFF7A00) : Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
