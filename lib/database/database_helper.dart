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
      version: 5,
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
  precio2 REAL DEFAULT 0,
  precio3 REAL DEFAULT 0,
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
  descuento REAL DEFAULT 0,
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
  descuento REAL DEFAULT 0,
  estado TEXT,
  estadoPago TEXT DEFAULT 'pendiente',
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

    await _crearTablaMovimientosStock(db);
  }

  Future<void> _crearTablaMovimientosStock(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS movimientos_stock(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productoId INTEGER NOT NULL,
  tipo TEXT NOT NULL,
  cantidad INTEGER NOT NULL,
  fecha TEXT NOT NULL,
  remitoId TEXT,
  motivo TEXT,
  FOREIGN KEY(productoId) REFERENCES productos(id)
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE comparacion ADD COLUMN marca TEXT DEFAULT ''",
      );
    }

    if (oldVersion < 3) {
      await _crearTablaMovimientosStock(db);
    }

    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE remitos ADD COLUMN descuento REAL DEFAULT 0',
      );
      await db.execute(
        "ALTER TABLE remitos ADD COLUMN estadoPago TEXT DEFAULT 'pendiente'",
      );
    }

    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE productos ADD COLUMN precio2 REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE productos ADD COLUMN precio3 REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE clientes ADD COLUMN descuento REAL DEFAULT 0',
      );
    }
  }

  Future<void> cerrar() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }
}
