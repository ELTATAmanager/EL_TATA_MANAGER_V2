import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/compra.dart';
import '../models/compra_detalle.dart';
import '../models/movimiento_stock.dart';
import 'auth_service.dart';

class CompraService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<String> generarNumero() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery(
      "SELECT MAX(CAST(SUBSTR(numero,3) AS INTEGER)) AS maxN FROM compras WHERE numero LIKE 'C-%'",
    );
    final maxN = (r.first['maxN'] as num?)?.toInt() ?? 0;
    return 'C-${(maxN + 1).toString().padLeft(5, '0')}';
  }

  /// Inserts a purchase along with its items, updates product stock and cost,
  /// and records a price-history entry whenever the cost changes.
  Future<int> insertar(Compra compra, List<CompraDetalle> items) async {
    final db = await dbHelper.database;

    return db.transaction((txn) async {
      final compraId = await txn.insert('compras', {
        'proveedorId': compra.proveedorId,
        'proveedorNombre': compra.proveedorNombre,
        'numero': compra.numero,
        'fecha': compra.fecha.toIso8601String(),
        'total': compra.total,
        'observaciones': compra.observaciones,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'estado': compra.estado,
      });

      for (final item in items) {
        await txn.insert('compra_items', {
          'compraId': compraId,
          'productoId': item.productoId,
          'productoDescripcion': item.productoDescripcion,
          'cantidad': item.cantidad,
          'costo': item.costo,
          'subtotal': item.subtotal,
        });

        final productoRows = await txn.query(
          'productos',
          columns: ['costo'],
          where: 'id = ?',
          whereArgs: [item.productoId],
          limit: 1,
        );
        final costoAnterior =
            (productoRows.isNotEmpty ? productoRows.first['costo'] as num? : 0)
                    ?.toDouble() ??
                0;

        await txn.rawUpdate(
          'UPDATE productos SET stock = stock + ?, costo = ? WHERE id = ?',
          [item.cantidad, item.costo, item.productoId],
        );

        if (costoAnterior != item.costo) {
          await txn.insert('historial_precios', {
            'productoId': item.productoId,
            'fecha': DateTime.now().toIso8601String(),
            'usuario': AuthService.instance.currentUser?.usuario ?? 'sistema',
            'costoAnterior': costoAnterior,
            'costoNuevo': item.costo,
            'motivo': 'Compra ${compra.numero}',
          });
        }

        final movimiento = MovimientoStock(
          productoId: item.productoId,
          tipo: 'entrada',
          cantidad: item.cantidad,
          fecha: DateTime.now(),
          remitoId: compraId.toString(),
          motivo: 'Entrada por compra ${compra.numero}',
        );

        await txn.insert(
          'movimientos_stock',
          movimiento.toMap()..remove('id'),
        );
      }

      return compraId;
    });
  }

  Future<List<Map<String, dynamic>>> obtenerTodasConProveedor() async {
    final db = await dbHelper.database;
    return db.rawQuery('''
      SELECT c.*, p.nombre AS proveedorNombreActual
      FROM compras c
      LEFT JOIN proveedores p ON p.id = c.proveedorId
      ORDER BY datetime(c.fecha) DESC, datetime(c.fechaCreacion) DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> obtenerItems(int compraId) async {
    final db = await dbHelper.database;
    return db.rawQuery('''
      SELECT ci.*, p.codigo, p.marca
      FROM compra_items ci
      LEFT JOIN productos p ON p.id = ci.productoId
      WHERE ci.compraId = ?
    ''', [compraId]);
  }

  Future<void> anular(int id) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      final compras = await txn.query(
        'compras',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (compras.isEmpty) return;

      final compra = compras.first;
      if (compra['estado'] == 'anulada') return;

      final items = await txn.query(
        'compra_items',
        where: 'compraId = ?',
        whereArgs: [id],
      );

      for (final item in items) {
        final productoId = item['productoId'] as int;
        final cantidad = item['cantidad'] as int? ?? 0;

        await txn.rawUpdate(
          'UPDATE productos SET stock = stock - ? WHERE id = ?',
          [cantidad, productoId],
        );

        final movimiento = MovimientoStock(
          productoId: productoId,
          tipo: 'reversion',
          cantidad: cantidad,
          fecha: DateTime.now(),
          remitoId: id.toString(),
          motivo: 'Reversión de compra ${compra['numero']}',
        );

        await txn.insert(
          'movimientos_stock',
          movimiento.toMap()..remove('id'),
        );
      }

      await txn.update(
        'compras',
        {'estado': 'anulada'},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> cantidad() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) total FROM compras');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<double> totalCompras() async {
    final db = await dbHelper.database;
    final r = await db.rawQuery(
      "SELECT SUM(total) total FROM compras WHERE estado != 'anulada'",
    );
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }
}
