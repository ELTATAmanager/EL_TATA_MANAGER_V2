import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/cliente.dart';

class ClienteService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> insertar(Cliente cliente) async {
    final db = await dbHelper.database;

    return await db.insert(
      "clientes",
      cliente.toMap(),
    );
  }

  Future<int> actualizar(Cliente cliente) async {
    final db = await dbHelper.database;

    return await db.update(
      "clientes",
      cliente.toMap(),
      where: "id=?",
      whereArgs: [cliente.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      "clientes",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<List<Cliente>> obtenerTodos() async {
    final db = await dbHelper.database;

    final resultado = await db.query(
      "clientes",
      orderBy: "nombre",
    );

    return resultado
        .map((e) => Cliente.fromMap(e))
        .toList();
  }
}
