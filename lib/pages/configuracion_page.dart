import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/branding_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _mostrarImagenes = true;

  // Branding
  final _nombreCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  String _logoPath = '';
  bool _guardandoBranding = false;

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
    _cargarBranding();
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    _nombreCtrl.dispose();
    _sloganCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _cargarBranding() {
    final b = BrandingService.instance;
    _nombreCtrl.text = b.nombre;
    _sloganCtrl.text = b.slogan;
    _telefonoCtrl.text = b.telefono;
    _direccionCtrl.text = b.direccion;
    setState(() => _logoPath = b.logoPath);
  }

  Future<void> _elegirLogo() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _logoPath = img.path);
  }

  Future<void> _guardarBranding() async {
    setState(() => _guardandoBranding = true);
    await BrandingService.instance.guardar(
      nombre: _nombreCtrl.text.trim(),
      slogan: _sloganCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      logoPath: _logoPath,
    );
    if (!mounted) return;
    setState(() => _guardandoBranding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos del negocio guardados')),
    );
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
        child: Column(
          children: [
            // ── Branding ──────────────────────────────
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          'MI NEGOCIO',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _elegirLogo,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: colorScheme.primaryContainer,
                              backgroundImage: _logoPath.isNotEmpty
                                  ? FileImage(File(_logoPath))
                                  : null,
                              child: _logoPath.isEmpty
                                  ? Icon(Icons.store,
                                      size: 40, color: colorScheme.primary)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: colorScheme.primary,
                                child: const Icon(Icons.edit,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Tocá para cambiar el logo',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sloganCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Slogan / descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.short_text),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _guardandoBranding ? null : _guardarBranding,
                        icon: _guardandoBranding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('GUARDAR DATOS DEL NEGOCIO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Tema ──────────────────────────────────
            Card(
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
        const SizedBox(height: 16),
      ],
    ),
  ),
);
  }
}
