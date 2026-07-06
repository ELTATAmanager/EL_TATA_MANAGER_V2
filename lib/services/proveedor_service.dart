import '../database/database_helper.dart';
import '../models/proveedor.dart';
import 'package:sqflite/sqflite.dart';

class ProveedorService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertar(Proveedor proveedor) async {
    final db = await _dbHelper.database;

    return await db.insert(
      'proveedores',
      {
        ...proveedor.toMap(),
        'fechaCreacion': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(Proveedor proveedor) async {
    final db = await _dbHelper.database;

    return await db.update(
      'proveedores',
      proveedor.toMap(),
      where: 'id = ?',
      whereArgs: [proveedor.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;

    return await db.delete(
      'proveedores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Proveedor?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;

    final resultado = await db.query(
      'proveedores',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Proveedor.fromMap(resultado.first);
  }

  Future<List<Proveedor>> obtenerTodos() async {
    final db = await _dbHelper.database;

    final resultado = await db.query(
      'proveedores',
      where: 'activo = 1',
      orderBy: 'nombre',
    );

    return resultado
        .map((e) => Proveedor.fromMap(e))
        .toList();
  }

  Future<int> cantidad() async {
    final db = await _dbHelper.database;

    final resultado = await db.rawQuery(
      'SELECT COUNT(*) total FROM proveedores',
    );

    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<void> cargarProveedoresIniciales() async {
    if (await cantidad() > 0) {
      return;
    }

    final proveedores = [
      "Bisso",
      "Arola",
      "Washington",
      "Fana",
      "Tapper",
      "Cuero Sur",
      "Mercado Libre",
    ];

    for (final nombre in proveedores) {
      await insertar(
        Proveedor(
          nombre: nombre,
          telefono: "",
          email: "",
          observaciones: "",
        ),
      );
    }
  }
}
