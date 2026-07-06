import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _mostrarImagenes = true;

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChanged);
    _cargarPreferencias();
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _mostrarImagenes = prefs.getBool('mostrarImagenes') ?? true;
    });
  }

  Future<void> _setMostrarImagenes(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mostrarImagenes', value);
    if (!mounted) return;
    setState(() {
      _mostrarImagenes = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PERSONALIZÁ TU EXPERIENCIA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Colores del tema',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppTheme.coloresDisponibles.map((color) {
                    final selected = themeProvider.color == color;
                    return InkWell(
                      onTap: () => themeProvider.setColor(color),
                      borderRadius: BorderRadius.circular(24),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: color,
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Fuente',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: themeProvider.fuente,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: AppTheme.fuentesDisponibles
                      .map(
                        (fuente) => DropdownMenuItem(
                          value: fuente,
                          child: Text(fuente),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setFuente(value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Modo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 360;
                    return ToggleButtons(
                      isSelected: [
                        themeProvider.mode == ThemeMode.light,
                        themeProvider.mode == ThemeMode.dark,
                        themeProvider.mode == ThemeMode.system,
                      ],
                      onPressed: (index) {
                        final mode = [
                          ThemeMode.light,
                          ThemeMode.dark,
                          ThemeMode.system,
                        ][index];
                        themeProvider.setMode(mode);
                      },
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Claro'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Oscuro'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Sistema'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Configuración avanzada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _mostrarImagenes,
                  onChanged: _setMostrarImagenes,
                  title: const Text('Mostrar imágenes'),
                  subtitle: const Text('Guardado localmente en el dispositivo'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline),
                  title: Text('3 listas de precios'),
                  subtitle: Text(
                    'Lista 1, Lista 2 y Lista 3 ya están disponibles para cada producto.',
                  ),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.place_outlined),
                  title: Text('Ubicaciones'),
                  subtitle: Text(
                    'Podés seguir usando ubicaciones para ordenar mejor el stock.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
