import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/producto.dart';
import 'auth_service.dart';

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

    if (producto.id != null) {
      final anterior = await db.query(
        'productos',
        columns: ['costo'],
        where: 'id = ?',
        whereArgs: [producto.id],
        limit: 1,
      );
      final costoAnterior =
          (anterior.isNotEmpty ? anterior.first['costo'] as num? : null)
              ?.toDouble();
      if (costoAnterior != null && costoAnterior != producto.costo) {
        await db.insert('historial_precios', {
          'productoId': producto.id,
          'fecha': DateTime.now().toIso8601String(),
          'usuario': AuthService.instance.currentUser?.usuario ?? 'sistema',
          'costoAnterior': costoAnterior,
          'costoNuevo': producto.costo,
          'motivo': 'Edición de producto',
        });
      }
    }

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