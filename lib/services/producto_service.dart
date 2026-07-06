import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/producto.dart';
import 'auth_service.dart';

class ProductoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  String _snapshot(Producto producto) {
    return jsonEncode({
      'id': producto.id,
      'codigo': producto.codigo,
      'descripcion': producto.descripcion,
      'marca': producto.marca,
      'categoria': producto.categoria,
      'stock': producto.stock,
      'costo': producto.costo,
      'precio': producto.precio,
      'precio2': producto.precio2,
      'precio3': producto.precio3,
    });
  }

  Future<int> insertar(Producto producto) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await AuthService.instance.registrarCambio(
      'ALTA_PRODUCTO',
      'productos',
      'Nuevo producto: ${producto.descripcion}',
      valorNuevo: _snapshot(producto.copyWith(id: id)),
    );

    return id;
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
    final resultado = await db.query('productos', orderBy: 'descripcion');
    return resultado.map((e) => Producto.fromMap(e)).toList();
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
    final resultado = await db.rawQuery('SELECT COUNT(*) total FROM productos');
    return Sqflite.firstIntValue(resultado)! > 0;
  }

  Future<int> actualizar(Producto producto) async {
    final db = await _databaseHelper.database;
    Producto? anteriorProducto;

    if (producto.id != null) {
      final anterior = await db.query(
        'productos',
        where: 'id = ?',
        whereArgs: [producto.id],
        limit: 1,
      );
      if (anterior.isNotEmpty) {
        anteriorProducto = Producto.fromMap(anterior.first);
        final costoAnterior = anteriorProducto.costo;
        final precioAnterior = anteriorProducto.precio;
        final listasModificadas = <String>[];
        if (precioAnterior != producto.precio) {
          listasModificadas.add('Lista 1');
        }
        if (anteriorProducto.precio2 != producto.precio2) {
          listasModificadas.add('Lista 2');
        }
        if (anteriorProducto.precio3 != producto.precio3) {
          listasModificadas.add('Lista 3');
        }

        if (costoAnterior != producto.costo || listasModificadas.isNotEmpty) {
          final variacion = precioAnterior > 0
              ? ((producto.precio - precioAnterior) / precioAnterior) * 100
              : 0.0;
          await db.insert('historial_precios', {
            'productoId': producto.id,
            'fecha': DateTime.now().toIso8601String(),
            'usuario': AuthService.instance.currentUser?.usuario ?? 'sistema',
            'costoAnterior': costoAnterior,
            'costoNuevo': producto.costo,
            'precioAnterior': precioAnterior,
            'precioNuevo': producto.precio,
            'porcentaje': variacion,
            'listaModificada':
                listasModificadas.isEmpty ? 'Costo' : listasModificadas.join(', '),
            'motivo': 'Edición de producto',
          });
        }
      }
    }

    final result = await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );

    await AuthService.instance.registrarCambio(
      'MODIFICACION_PRODUCTO',
      'productos',
      'Producto actualizado: ${producto.descripcion}',
      valorAnterior: anteriorProducto != null ? _snapshot(anteriorProducto) : null,
      valorNuevo: _snapshot(producto),
    );

    return result;
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;
    final anterior = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final producto = anterior.isNotEmpty ? Producto.fromMap(anterior.first) : null;

    final result = await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (producto != null) {
      await AuthService.instance.registrarCambio(
        'BAJA_PRODUCTO',
        'productos',
        'Producto eliminado: ${producto.descripcion}',
        valorAnterior: _snapshot(producto),
      );
    }

    return result;
  }
}
