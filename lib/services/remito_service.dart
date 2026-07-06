import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/remito.dart';
import '../models/remito_detalle.dart';

class RemitoService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<String> generarNumero() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) total FROM remitos');
    final n = (Sqflite.firstIntValue(r) ?? 0) + 1;
    return 'R-${n.toString().padLeft(5, '0')}';
  }

  Future<int> insertar(Remito remito, List<RemitoDetalle> items) async {
    final db = await dbHelper.database;

    final remitoId = await db.insert(
      'remitos',
      {
        'numero': remito.numero,
        'clienteId': remito.clienteId != null
            ? int.tryParse(remito.clienteId!)
            : null,
        'fecha': remito.fecha.toIso8601String(),
        'total': remito.total,
        'estado': remito.estado,
        'observaciones': remito.observaciones,
        'fechaCreacion': DateTime.now().toIso8601String(),
      },
    );

    for (final item in items) {
      await db.insert('remito_items', {
        'remitoId': remitoId,
        'productoId': item.productoId,
        'cantidad': item.cantidad,
        'precio': item.precioUnitario,
        'subtotal': item.subtotal,
      });
    }

    return remitoId;
  }

  Future<List<Map<String, dynamic>>> obtenerTodosConCliente() async {
    final db = await dbHelper.database;
    return db.rawQuery('''
      SELECT r.*, c.nombre AS clienteNombre
      FROM remitos r
      LEFT JOIN clientes c ON c.id = r.clienteId
      ORDER BY r.fechaCreacion DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> obtenerItems(int remitoId) async {
    final db = await dbHelper.database;
    return db.rawQuery('''
      SELECT ri.*, p.descripcion, p.codigo, p.marca
      FROM remito_items ri
      JOIN productos p ON p.id = ri.productoId
      WHERE ri.remitoId = ?
    ''', [remitoId]);
  }

  Future<void> anular(int id) async {
    final db = await dbHelper.database;
    await db.update(
      'remitos',
      {'estado': 'anulado'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> cantidad() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) total FROM remitos');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<double> totalVentas() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery(
      "SELECT SUM(total) total FROM remitos WHERE estado != 'anulado'",
    );
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }
}
