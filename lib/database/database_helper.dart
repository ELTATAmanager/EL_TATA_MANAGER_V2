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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
CREATE TABLE proveedores(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  telefono TEXT,
  email TEXT,
  observaciones TEXT,
  fechaCreacion TEXT,
  activo INTEGER DEFAULT 1
)
''');

    await db.execute('''
CREATE TABLE clientes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  telefono TEXT,
  email TEXT,
  direccion TEXT,
  observaciones TEXT,
  fechaCreacion TEXT,
  activo INTEGER DEFAULT 1
)
''');

    await db.execute('''
CREATE TABLE remitos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  numero TEXT NOT NULL,
  clienteId INTEGER,
  fecha TEXT,
  total REAL DEFAULT 0,
  estado TEXT,
  observaciones TEXT,
  fechaCreacion TEXT,
  FOREIGN KEY(clienteId) REFERENCES clientes(id)
)
''');

    await db.execute('''
CREATE TABLE remito_items(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  remitoId INTEGER,
  productoId INTEGER,
  cantidad INTEGER,
  precio REAL,
  subtotal REAL,
  FOREIGN KEY(remitoId) REFERENCES remitos(id),
  FOREIGN KEY(productoId) REFERENCES productos(id)
)
''');

    await db.execute('''
CREATE TABLE comparacion(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT,
  descripcion TEXT,
  precioViejo REAL,
  precioNuevo REAL,
  estado TEXT,
  marca TEXT
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE comparacion ADD COLUMN marca TEXT DEFAULT ''",
      );
    }
  }

  Future<void> cerrar() async {
    final db = await database;
    await db.close();
  }
}
