import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/producto.dart';

class ProductoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Producto producto) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertarLista(List<Producto> productos) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final producto in productos) {
      batch.insert(
        'productos',
        producto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final resultado = await db.query(
      'productos',
      orderBy: 'descripcion',
    );

    return resultado
        .map((e) => Producto.fromMap(e))
        .toList();
  }

  Future<Producto?> buscarPorCodigo(String codigo) async {
    final db = await _databaseHelper.database;

    final resultado = await db.query(
      'productos',
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Producto.fromMap(resultado.first);
  }

  Future<bool> tieneProductos() async {
    final db = await _databaseHelper.database;

    final resultado = await db.rawQuery(
      'SELECT COUNT(*) total FROM productos',
    );

    return Sqflite.firstIntValue(resultado)! > 0;
  }

  Future<int> actualizar(Producto producto) async {
    final db = await _databaseHelper.database;

    return db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}