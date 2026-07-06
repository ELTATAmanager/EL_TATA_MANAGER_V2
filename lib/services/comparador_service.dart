import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/comparacion.dart';
import '../models/producto.dart';
import 'producto_service.dart';

class ComparadorService {
  final ProductoService productoService = ProductoService();

  Future<void> limpiarComparaciones() async {
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
    await limpiarComparaciones();
    for (final productoNuevo in productosImportados) {
      final productoViejo =
          await productoService.buscarPorCodigo(productoNuevo.codigo);
      if (productoViejo == null) {
        await guardarComparacion(
          Comparacion(
            codigo: productoNuevo.codigo,
            descripcion: productoNuevo.descripcion,
            precioViejo: 0,
            precioNuevo: productoNuevo.precio,
            estado: 'NUEVO',
            marca: productoNuevo.marca,
          ),
        );
        continue;
      }
      String estado = 'IGUAL';
      if (productoNuevo.precio > productoViejo.precio) {
        estado = 'SUBIO';
      } else if (productoNuevo.precio < productoViejo.precio) {
        estado = 'BAJO';
      }
      await guardarComparacion(
        Comparacion(
          codigo: productoNuevo.codigo,
          descripcion: productoNuevo.descripcion,
          precioViejo: productoViejo.precio,
          precioNuevo: productoNuevo.precio,
          estado: estado,
          marca: productoNuevo.marca,
        ),
      );
    }
  }

  Future<void> actualizarProductos() async {
    final comparaciones = await obtenerComparacion();
    for (final comp in comparaciones) {
      final producto = await productoService.buscarPorCodigo(comp.codigo);
      if (producto != null) {
        await productoService.actualizar(
          producto.copyWith(precio: comp.precioNuevo),
        );
      } else {
        await productoService.insertar(
          Producto(
            codigo: comp.codigo,
            descripcion: comp.descripcion,
            marca: comp.marca,
            categoria: '',
            proveedor: '',
            ubicacion: '',
            stock: 0,
            costo: 0,
            precio: comp.precioNuevo,
            observaciones: '',
            foto: '',
          ),
        );
      }
    }
  }

  Future<int> cantidadAumentos() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db
        .rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='SUBIO'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadBajas() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db
        .rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='BAJO'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadNuevos() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db
        .rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='NUEVO'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> cantidadIguales() async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db
        .rawQuery("SELECT COUNT(*) FROM comparacion WHERE estado='IGUAL'");
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
