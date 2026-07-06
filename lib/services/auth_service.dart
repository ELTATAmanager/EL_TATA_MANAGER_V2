import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/usuario.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  Usuario? currentUser;

  bool get isLoggedIn => currentUser != null;

  /// Returns a SHA-256 hex digest of [password].
  static String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Attempts login. Returns the user on success, null on failure.
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
    currentUser = Usuario.fromMap(result.first);
    await _registrarAudit('LOGIN', 'Inicio de sesión');
    return currentUser;
  }

  Future<void> logout() async {
    await _registrarAudit('LOGOUT', 'Cierre de sesión');
    currentUser = null;
  }

  /// Registers an audit entry for the current user.
  Future<void> registrarAccion(String accion, String detalle) async {
    await _registrarAudit(accion, detalle);
  }

  Future<void> _registrarAudit(String accion, String detalle) async {
    if (currentUser == null && accion != 'LOGIN') return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('audit_log', {
      'usuario': currentUser?.usuario ?? 'sistema',
      'accion': accion,
      'detalle': detalle,
      'fecha': DateTime.now().toIso8601String(),
    });
  }
}
