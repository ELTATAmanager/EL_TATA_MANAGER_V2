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
  int selectedSidebar = 0;
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
        title: 'Productos',
        subtitle: 'Catálogo completo',
        color: AppVisuals.primaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ProductosPage()),
      ),
      _ModuleConfig(
        icon: Icons.groups_rounded,
        title: 'Clientes',
        subtitle: 'Gestión de clientes',
        color: AppVisuals.secondaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ClientesPage()),
      ),
      _ModuleConfig(
        icon: Icons.local_shipping_rounded,
        title: 'Proveedores',
        subtitle: 'Datos y contacto',
        color: AppVisuals.info(colorScheme),
        onTap: () => _abrirPagina(const ProveedoresPage()),
      ),
      _ModuleConfig(
        icon: Icons.description_rounded,
        title: 'Remitos',
        subtitle: 'Ventas y entregas',
        color: AppVisuals.warning(colorScheme),
        onTap: () => _abrirPagina(const RemitosPage()),
      ),
      _ModuleConfig(
        icon: Icons.warehouse_rounded,
        title: 'Stock',
        subtitle: 'Movimientos y saldo',
        color: AppVisuals.success(colorScheme),
        onTap: () => _abrirPagina(const StockPage()),
      ),
      _ModuleConfig(
        icon: Icons.query_stats_rounded,
        title: 'Dashboard',
        subtitle: 'Métricas del negocio',
        color: AppVisuals.tertiaryAccent(colorScheme),
        onTap: () => _abrirPagina(const DashboardPage()),
      ),
      _ModuleConfig(
        icon: Icons.cloud_upload_rounded,
        title: 'Respaldo',
        subtitle: 'Importar / Exportar',
        color: AppVisuals.neutral(colorScheme),
        onTap: () => _abrirPagina(const BackupPage()),
      ),
      _ModuleConfig(
        icon: Icons.tune_rounded,
        title: 'Configuración',
        subtitle: 'Tema y ajustes',
        color: AppVisuals.primaryAccent(colorScheme),
        onTap: () => _abrirPagina(const ConfiguracionPage()),
      ),
    ];
  }

  void _onSidebarTap(int index) {
    setState(() => selectedSidebar = index);
    switch (index) {
      case 1:
        _abrirPagina(const ProductosPage());
        break;
      case 2:
        _abrirPagina(const ClientesPage());
        break;
      case 3:
        _abrirPagina(const ProveedoresPage());
        break;
      case 4:
        _abrirPagina(const RemitosPage());
        break;
      case 5:
        _abrirPagina(const StockPage());
        break;
      case 6:
        _abrirPagina(const DashboardPage());
        break;
      case 7:
        _abrirPagina(const ConfiguracionPage());
        break;
      default:
        break;
    }
  }

  void _onBottomTap(int index) {
    setState(() => selectedBottom = index);
    switch (index) {
      case 1:
        _abrirPagina(const ProductosPage());
        break;
      case 2:
        analizar();
        break;
      case 3:
        _abrirPagina(const RemitosPage());
        break;
      case 4:
        _abrirPagina(const ConfiguracionPage());
        break;
      default:
        break;
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final modules = _buildModules(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        _DesktopSidebar(
          selectedIndex: selectedSidebar,
          onTap: _onSidebarTap,
          title: BrandingService.instance.nombre,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: BrandingService.instance.nombre,
                  subtitle: BrandingService.instance.slogan,
                  loading: cargando,
                  onAnalyze: analizar,
                ),
                const SizedBox(height: 14),
                const _StatsRow(),
                const SizedBox(height: 14),
                Text(
                  'Módulos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 1250 ? 4 : 3;
                      return GridView.builder(
                        itemCount: modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.65,
                        ),
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return _ModuleCard(
                            icon: module.icon,
                            title: module.title,
                            subtitle: module.subtitle,
                            color: module.color,
                            onTap: module.onTap,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final modules = _buildModules(context);

    return Column(
      children: [
        _TopBar(
          title: BrandingService.instance.nombre,
          subtitle: BrandingService.instance.slogan,
          loading: cargando,
          onAnalyze: analizar,
          compact: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: _StatsRow(compact: true),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final module = modules[index];
              return _ModuleCard(
                icon: module.icon,
                title: module.title,
                subtitle: module.subtitle,
                color: module.color,
                onTap: module.onTap,
                compact: true,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;

        return Scaffold(
          appBar: desktop
              ? null
              : AppBar(
                  title: Text(BrandingService.instance.nombre),
                  centerTitle: true,
                ),
          body: desktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
          bottomNavigationBar: desktop
              ? null
              : BottomNavigationBar(
                  currentIndex: selectedBottom,
                  onTap: _onBottomTap,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.inventory_2_rounded),
                      label: 'Productos',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle_rounded),
                      label: 'Nuevo',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.point_of_sale_rounded),
                      label: 'Ventas',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.more_horiz_rounded),
                      label: 'Más',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final String title;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D111A) : colorScheme.surfaceContainer,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.storefront_rounded, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _SidebarTile(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  selected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _SidebarTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'Productos',
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _SidebarTile(
                  icon: Icons.groups_rounded,
                  label: 'Clientes',
                  selected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
                _SidebarTile(
                  icon: Icons.local_shipping_rounded,
                  label: 'Proveedores',
                  selected: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
                _SidebarTile(
                  icon: Icons.description_rounded,
                  label: 'Remitos',
                  selected: selectedIndex == 4,
                  onTap: () => onTap(4),
                ),
                _SidebarTile(
                  icon: Icons.warehouse_rounded,
                  label: 'Stock',
                  selected: selectedIndex == 5,
                  onTap: () => onTap(5),
                ),
                _SidebarTile(
                  icon: Icons.query_stats_rounded,
                  label: 'Dashboard',
                  selected: selectedIndex == 6,
                  onTap: () => onTap(6),
                ),
                _SidebarTile(
                  icon: Icons.tune_rounded,
                  label: 'Configuración',
                  selected: selectedIndex == 7,
                  onTap: () => onTap(7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: selected,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.15),
        leading: Icon(icon, size: 20),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onAnalyze;
  final bool compact;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onAnalyze,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: compact ? const EdgeInsets.fromLTRB(12, 12, 12, 10) : EdgeInsets.zero,
      elevation: compact ? 1 : 2,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 12,
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: loading ? null : onAnalyze,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_rounded),
              label: const Text('Analizar lista'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final bool compact;

  const _StatsRow({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = [
      _InfoStatData(
        title: 'Productos',
        value: 'Gestión',
        icon: Icons.inventory_2_rounded,
        color: AppVisuals.primaryAccent(colorScheme),
      ),
      _InfoStatData(
        title: 'Stock',
        value: 'Control',
        icon: Icons.layers_rounded,
        color: AppVisuals.success(colorScheme),
      ),
      _InfoStatData(
        title: 'Ventas',
        value: 'Remitos',
        icon: Icons.payments_rounded,
        color: AppVisuals.info(colorScheme),
      ),
      _InfoStatData(
        title: 'Sincronización',
        value: 'Respaldo',
        icon: Icons.cloud_done_rounded,
        color: AppVisuals.warning(colorScheme),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = compact || constraints.maxWidth < 900 ? 2 : 4;
        final height = compact ? 160.0 : 86.0;

        return SizedBox(
          height: height,
          child: GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: compact ? 2.15 : 2.8,
            ),
            itemBuilder: (context, index) => _InfoStatCard(data: cards[index]),
          ),
        );
      },
    );
  }
}

class _InfoStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _InfoStatCard extends StatelessWidget {
  final _InfoStatData data;

  const _InfoStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: data.color.withValues(alpha: 0.15),
              child: Icon(data.icon, color: data.color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

class _ModuleConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _ModuleConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool compact;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: compact ? 1 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 18 : 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: compact ? 18 : 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
