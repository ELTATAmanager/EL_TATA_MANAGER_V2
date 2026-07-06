import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/usuario.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  Usuario? currentUser;

  bool get isLoggedIn => currentUser != null;

  static String hashPassword(String password) => _hash(password);

  static String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Usuario?> login(String usuario, String password) async {
    final db = await DatabaseHelper.instance.database;
    final hashed = _hash(password);
    final result = await db.query(
      'usuarios',
      where: 'usuario = ? AND password = ? AND activo = 1',
      whereArgs: [usuario.trim(), hashed],
      limit: 1,
    );
    if (result.isEmpty) return null;

    final ahora = DateTime.now().toIso8601String();
    await db.update(
      'usuarios',
      {'ultimoAcceso': ahora},
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );

    currentUser = Usuario.fromMap({...result.first, 'ultimoAcceso': ahora});
    await _registrarAudit(
      'LOGIN',
      'Inicio de sesión',
      tablaAfectada: 'usuarios',
      valorNuevo: jsonEncode({
        'usuario': currentUser?.usuario,
        'rol': currentUser?.rol,
      }),
    );
    return currentUser;
  }

  Future<void> logout() async {
    await _registrarAudit(
      'LOGOUT',
      'Cierre de sesión',
      tablaAfectada: 'usuarios',
      valorAnterior: jsonEncode({'usuario': currentUser?.usuario}),
    );
    currentUser = null;
  }

  Future<void> registrarAccion(String accion, String detalle) async {
    await _registrarAudit(accion, detalle);
  }

  Future<void> registrarCambio(
    String accion,
    String tabla,
    String detalle, {
    String? valorAnterior,
    String? valorNuevo,
  }) async {
    await _registrarAudit(
      accion,
      detalle,
      tablaAfectada: tabla,
      valorAnterior: valorAnterior,
      valorNuevo: valorNuevo,
    );
  }

  Future<void> _registrarAudit(
    String accion,
    String detalle, {
    String? tablaAfectada,
    String? valorAnterior,
    String? valorNuevo,
  }) async {
    if (currentUser == null && accion != 'LOGIN') return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('audit_log', {
      'usuario': currentUser?.usuario ?? 'sistema',
      'accion': accion,
      'detalle': detalle,
      'tablaAfectada': tablaAfectada,
      'valorAnterior': valorAnterior,
      'valorNuevo': valorNuevo,
      'fecha': DateTime.now().toIso8601String(),
    });
  }
}
