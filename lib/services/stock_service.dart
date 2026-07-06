import '../database/database_helper.dart';
import '../models/movimiento_stock.dart';
import '../models/producto.dart';

class StockService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> obtenerMovimientos({int? productoId}) async {
    final db = await dbHelper.database;
    return db.rawQuery(
      '''
      SELECT m.*, p.descripcion AS productoNombre, p.codigo AS productoCodigo, p.stock AS stockActual
      FROM movimientos_stock m
      JOIN productos p ON p.id = m.productoId
      ${productoId != null ? 'WHERE m.productoId = ?' : ''}
      ORDER BY datetime(m.fecha) DESC, m.id DESC
      ''',
      productoId != null ? [productoId] : [],
    );
  }

  Future<int> registrarMovimiento(MovimientoStock movimiento) async {
    final db = await dbHelper.database;

    return db.transaction((txn) async {
      final movimientoId = await txn.insert(
        'movimientos_stock',
        movimiento.toMap()..remove('id'),
      );

      final multiplicador = movimiento.tipo == 'salida' ? -1 : 1;
      await txn.rawUpdate(
        'UPDATE productos SET stock = stock + ? WHERE id = ?',
        [movimiento.cantidad * multiplicador, movimiento.productoId],
      );

      return movimientoId;
    });
  }

  Future<List<Producto>> obtenerProductosConStockBajo({int limite = 5}) async {
    final db = await dbHelper.database;
    final resultado = await db.query(
      'productos',
      where: 'stock <= ?',
      whereArgs: [limite],
      orderBy: 'stock ASC, descripcion',
    );

    return resultado.map((e) => Producto.fromMap(e)).toList();
  }
}
