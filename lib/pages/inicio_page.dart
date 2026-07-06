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
  int railIndex = 0;

  Future<void> analizar() async {
    setState(() {
      cargando = true;
    });

    try {
      final cantidad = await csvService.analizarArchivo();

      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      if (cantidad == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se seleccionó ningún archivo."),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ComparacionPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void _abrirPagina(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  List<_ModuleConfig> _buildModules(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      _ModuleConfig(
        icon: Icons.inventory_2_rounded,
        title: "Productos",
        color: AppVisuals.primaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ProductosPage()),
      ),
      _ModuleConfig(
        icon: Icons.local_shipping_rounded,
        title: "Proveedores",
        color: AppVisuals.info(colorScheme),
        onTap: () => _abrirPagina(const ProveedoresPage()),
      ),
      _ModuleConfig(
        icon: Icons.groups_rounded,
        title: "Clientes",
        color: AppVisuals.secondaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ClientesPage()),
      ),
      _ModuleConfig(
        icon: Icons.description_rounded,
        title: "Remitos",
        color: AppVisuals.warning(colorScheme),
        onTap: () => _abrirPagina(const RemitosPage()),
      ),
      _ModuleConfig(
        icon: Icons.warehouse_rounded,
        title: "Stock",
        color: AppVisuals.success(colorScheme),
        onTap: () => _abrirPagina(const StockPage()),
      ),
      _ModuleConfig(
        icon: Icons.query_stats_rounded,
        title: "Dashboard",
        color: AppVisuals.tertiaryAccent(colorScheme),
        onTap: () => _abrirPagina(const DashboardPage()),
      ),
      _ModuleConfig(
        icon: Icons.cloud_upload_rounded,
        title: "Respaldo",
        color: AppVisuals.neutral(colorScheme),
        onTap: () => _abrirPagina(const BackupPage()),
      ),
      _ModuleConfig(
        icon: Icons.tune_rounded,
        title: "Configuración",
        color: AppVisuals.primaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ConfiguracionPage()),
      ),
    ];
  }

  void _onRailSelected(int index) {
    setState(() => railIndex = index);
    switch (index) {
      case 1:
        _abrirPagina(const ProductosPage());
        break;
      case 2:
        _abrirPagina(const ClientesPage());
        break;
      case 3:
        _abrirPagina(const RemitosPage());
        break;
      case 4:
        _abrirPagina(const DashboardPage());
        break;
      case 5:
        _abrirPagina(const ConfiguracionPage());
        break;
      default:
        break;
    }
  }

  Widget _buildHomeContent({required int crossAxisCount}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final modules = _buildModules(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: colorScheme.primary,
                        size: 64,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        BrandingService.instance.nombre,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        BrandingService.instance.slogan,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: cargando ? null : analizar,
                          icon: const Icon(Icons.analytics),
                          label: const Text("ANALIZAR LISTA"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (cargando) const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "MÓDULOS",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return _ModuleCard(
                    icon: module.icon,
                    title: module.title,
                    color: module.color,
                    onTap: module.onTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(BrandingService.instance.nombre),
        centerTitle: true,
        actions: [
          IconButton(
          icon: const Icon(Icons.query_stats_rounded),
            tooltip: "Dashboard",
            onPressed: () {
              _abrirPagina(const DashboardPage());
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            final crossAxisCount = constraints.maxWidth >= 1000 ? 3 : 2;
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: railIndex,
                  onDestinationSelected: _onRailSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Inicio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2_rounded),
                      label: Text('Productos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.groups_outlined),
                      selectedIcon: Icon(Icons.groups_rounded),
                      label: Text('Clientes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.description_outlined),
                      selectedIcon: Icon(Icons.description_rounded),
                      label: Text('Remitos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.query_stats_outlined),
                      selectedIcon: Icon(Icons.query_stats_rounded),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune_rounded),
                      label: Text('Config'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildHomeContent(crossAxisCount: crossAxisCount)),
              ],
            );
          }

          return _buildHomeContent(crossAxisCount: 2);
        },
      ),
    );
  }
}

class _ModuleConfig {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _ModuleConfig({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
