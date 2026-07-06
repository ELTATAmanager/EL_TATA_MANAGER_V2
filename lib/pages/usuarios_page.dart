import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/app_visuals.dart';
import 'usuario_form_page.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final UsuarioService _service = UsuarioService.instance;
  final TextEditingController _buscarController = TextEditingController();

  List<Usuario> _usuarios = [];
  List<Usuario> _filtrados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _usuarios = await _service.obtenerTodos();
    _filtrar(_buscarController.text, refrescar: false);
    if (!mounted) return;
    setState(() => _cargando = false);
  }

  void _filtrar(String texto, {bool refrescar = true}) {
    final query = texto.trim().toLowerCase();
    _filtrados = _usuarios.where((usuario) {
      return usuario.nombre.toLowerCase().contains(query) ||
          usuario.usuario.toLowerCase().contains(query) ||
          usuario.rol.toLowerCase().contains(query);
    }).toList();
    if (refrescar && mounted) setState(() {});
  }

  Future<void> _abrirFormulario({Usuario? usuario}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UsuarioFormPage(usuario: usuario)),
    );
    await _cargar();
  }

  Future<void> _toggleActivo(Usuario usuario) async {
    await _service.actualizar(usuario.copyWith(activo: !usuario.activo));
    await _cargar();
  }

  Color _colorRol(String rol) {
    final cs = Theme.of(context).colorScheme;
    switch (rol) {
      case 'admin':
        return AppVisuals.danger(cs);
      case 'supervisor':
        return AppVisuals.warning(cs);
      case 'solo_lectura':
        return AppVisuals.info(cs);
      default:
        return AppVisuals.success(cs);
    }
  }

  String _textoFecha(DateTime? fecha) {
    if (fecha == null) return 'Nunca';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo usuario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscarController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, usuario o rol...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? const Center(child: Text('No hay usuarios registrados.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                        itemCount: _filtrados.length,
                        itemBuilder: (context, index) {
                          final usuario = _filtrados[index];
                          final colorRol = _colorRol(usuario.rol);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorRol.withValues(alpha: .15),
                                child: Text(
                                  usuario.nombre.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: colorRol,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                usuario.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${usuario.usuario}'),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorRol.withValues(alpha: .15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          usuario.rol.replaceAll('_', ' ').toUpperCase(),
                                          style: TextStyle(
                                            color: colorRol,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (usuario.activo
                                                  ? AppVisuals.success(cs)
                                                  : AppVisuals.danger(cs))
                                              .withValues(alpha: .15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          usuario.activo ? 'ACTIVO' : 'INACTIVO',
                                          style: TextStyle(
                                            color: usuario.activo
                                                ? AppVisuals.success(cs)
                                                : AppVisuals.danger(cs),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Último acceso: ${_textoFecha(usuario.ultimoAcceso)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    onPressed: () => _abrirFormulario(usuario: usuario),
                                    icon: const Icon(Icons.edit_rounded),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    onPressed: () => _toggleActivo(usuario),
                                    icon: Icon(
                                      usuario.activo
                                          ? Icons.toggle_on_rounded
                                          : Icons.toggle_off_rounded,
                                    ),
                                    tooltip: usuario.activo
                                        ? 'Desactivar'
                                        : 'Activar',
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
