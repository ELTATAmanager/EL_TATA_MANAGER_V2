import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/comparacion.dart';
import '../models/producto.dart';
import 'producto_service.dart';

class ComparadorService {
  final ProductoService productoService = ProductoService();

  Future<void> limpiarComparacion() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('comparacion');
  }

  Future<void> guardarComparacion(Comparacion comparacion) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'comparacion',
      comparacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comparacion>> obtenerComparacion() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.query('comparacion', orderBy: 'descripcion');
    return resultado.map((e) => Comparacion.fromMap(e)).toList();
  }

  Future<void> compararProductos(List<Producto> productosImportados) async {
    await limpiarComparacion();
    for (final productoNuevo in productosImportados) {
      final productoViejo = await productoService.buscarPorCodigo(productoNuevo.codigo);
      if (productoViejo == null) {
        await guardarComparacion(
          Comparacion(
            codigo: productoNuevo.codigo,
            descripcion: productoNuevo.descripcion,
            precioViejo: 0,
            precioNuevo: productoNuevo.precio,
            estado: 'NUEVO',
          ),
        );
        continue;
      }
      String estado = 'IGUAL';
      if (productoNuevo.precio > productoViejo.precio) {
        estado = 'AUMENTO';
      } else if (productoNuevo.precio < productoViejo.precio) {
        estado = 'BAJA';
      }
      await guardarComparacion(
        Comparacion(
          codigo: productoNuevo.codigo,
          descripcion: productoNuevo.descripcion,
          precioViejo: productoViejo.precio,
          precioNuevo: productoNuevo.precio,
          estado: estado,
        ),
      );
    }
  }

  Future<int> cantidadAumentos() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='AUMENTO'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadBajas() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='BAJA'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadNuevos() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='NUEVO'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadIguales() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='IGUAL'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
