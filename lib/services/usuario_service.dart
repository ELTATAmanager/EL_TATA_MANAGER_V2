import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/usuario.dart';
import 'auth_service.dart';

class UsuarioService {
  static final UsuarioService instance = UsuarioService._();
  UsuarioService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Usuario>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final rows = await db.query('usuarios', orderBy: 'activo DESC, nombre ASC');
    return rows.map(Usuario.fromMap).toList();
  }

  Future<int> insertar(Usuario usuario) async {
    final db = await _dbHelper.database;
    final ahora = DateTime.now();
    return db.insert(
      'usuarios',
      usuario.copyWith(
        password: AuthService.hashPassword(usuario.password),
        fechaCreacion: usuario.fechaCreacion ?? ahora,
      ).toMap()
        ..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> actualizar(Usuario usuario, {String? nuevaPassword}) async {
    final db = await _dbHelper.database;
    final password = (nuevaPassword != null && nuevaPassword.trim().isNotEmpty)
        ? AuthService.hashPassword(nuevaPassword.trim())
        : usuario.password;

    return db.update(
      'usuarios',
      usuario.copyWith(password: password).toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.update(
      'usuarios',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> existeUsuario(String usuario) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'usuarios',
      columns: ['id'],
      where: 'LOWER(usuario) = ?',
      whereArgs: [usuario.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
