import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eltata.db');

    print('Base de datos: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE productos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  marca TEXT,
  categoria TEXT,
  proveedor TEXT,
  ubicacion TEXT,
  stock INTEGER DEFAULT 0,
  costo REAL DEFAULT 0,
  precio REAL DEFAULT 0,
  observaciones TEXT,
  foto TEXT
)
''');

    await db.execute('''
CREATE TABLE comparacion(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT,
  descripcion TEXT,
  precioViejo REAL,
  precioNuevo REAL,
  estado TEXT
)
''');
  }

  Future<void> cerrar() async {
    final db = await database;
    await db.close();
  }
}