import 'dart:io';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/branding_service.dart';
import 'auditoria_page.dart';
import 'backup_page.dart';
import 'clientes_page.dart';
import 'comparacion_page.dart';
import 'compras_page.dart';
import 'configuracion_page.dart';
import 'dashboard_page.dart';
import 'etiquetas_page.dart';
import 'listas_precio_page.dart';
import 'login_page.dart';
import 'productos_page.dart';
import 'proveedores_page.dart';
import 'remitos_page.dart';
import 'reportes_page.dart';
import 'stock_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Dashboard',
    'Productos',
    'Comparador de listas',
    'Stock',
    'Compras',
    'Remitos',
    'Clientes',
    'Proveedores',
    'Listas de Precios',
    'Reportes',
    'Etiquetas',
    'Auditoría',
    'Respaldo',
    'Configuración',
  ];

  static const _items = [
    (Icons.query_stats_rounded, 'Dashboard'),
    (Icons.inventory_2_rounded, 'Productos'),
    (Icons.compare_arrows_rounded, 'Comparador de listas'),
    (Icons.warehouse_rounded, 'Stock'),
    (Icons.shopping_cart_rounded, 'Compras'),
    (Icons.description_rounded, 'Remitos'),
    (Icons.groups_rounded, 'Clientes'),
    (Icons.local_shipping_rounded, 'Proveedores'),
    (Icons.sell_rounded, 'Listas de Precios'),
    (Icons.bar_chart_rounded, 'Reportes'),
    (Icons.label_rounded, 'Etiquetas'),
    (Icons.history_edu_rounded, 'Auditoría'),
    (Icons.cloud_upload_rounded, 'Respaldo'),
    (Icons.settings_rounded, 'Configuración'),
  ];

  late final List<Widget> _pages = [
    const DashboardPage(),
    const ProductosPage(),
    const ComparacionPage(),
    const StockPage(),
    const ComprasPage(),
    const RemitosPage(),
    const ClientesPage(),
    const ProveedoresPage(),
    const ListasPrecioPage(),
    const ReportesPage(),
    const EtiquetasPage(),
    const AuditoriaPage(),
    const BackupPage(),
    const ConfiguracionPage(),
  ];

  void _select(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 800;

        if (desktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            items: _items,
            onTap: _select,
            onLogout: _logout,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C111A),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF141A25),
              child: Text(
                (AuthService.instance.currentUser?.nombre ?? 'A')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFF7A00),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0C111A),
        width: 260,
        child: _SidebarContent(
          selectedIndex: _selectedIndex,
          items: _items,
          onTap: (i) {
            Navigator.of(context).pop(); // close drawer
            _select(i);
          },
          onLogout: _logout,
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    const quickItems = [0, 1, 5, 6]; // Dashboard, Productos, Remitos, Clientes
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0C111A),
      selectedItemColor: const Color(0xFFFF7A00),
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      currentIndex: quickItems.contains(_selectedIndex)
          ? quickItems.indexOf(_selectedIndex)
          : 0,
      onTap: (i) => _select(quickItems[i]),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.query_stats_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_rounded),
          label: 'Remitos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Clientes',
        ),
      ],
    );
  }
}

// ── Sidebar widgets ──────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF0B111C),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: _SidebarContent(
        selectedIndex: selectedIndex,
        items: items,
        onTap: onTap,
        onLogout: onLogout,
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  const _SidebarContent({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance;
    final logoPath = branding.logoPath;

    return Column(
      children: [
        // Header / logo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            children: [
              if (logoPath.isNotEmpty)
                CircleAvatar(
                  radius: 30,
                  backgroundImage: FileImage(File(logoPath)),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF7A00),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Color(0xFFFF7A00),
                    size: 28,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                branding.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              if (branding.slogan.isNotEmpty)
                Text(
                  branding.slogan,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Nav items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = selectedIndex == index;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFF7A00)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    item.$1,
                    color: selected ? Colors.white : Colors.white60,
                    size: 20,
                  ),
                  title: Text(
                    item.$2,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => onTap(index),
                ),
              );
            },
          ),
        ),
        // User + logout
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1F2937),
                child: Text(
                  (AuthService.instance.currentUser?.nombre ?? 'A')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AuthService.instance.currentUser?.nombre ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AuthService.instance.currentUser?.rol ?? '',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                tooltip: 'Cerrar sesión',
                onPressed: onLogout,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
