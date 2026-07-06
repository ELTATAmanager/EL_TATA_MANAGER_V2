import 'package:flutter/foundation.dart';
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

    debugPrint('Base de datos: $path');

    return openDatabase(
      path,
      version: 10,
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
    await _crearTablaUsuarios(db);
    await _crearTablaAuditLog(db);
    await _crearTablasCompras(db);
    await _crearTablaListasPrecios(db);
    await _crearTablaHistorialPrecios(db);
  }

  Future<void> _crearTablasCompras(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS compras(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  proveedorId INTEGER,
  proveedorNombre TEXT,
  numero TEXT,
  fecha TEXT,
  total REAL DEFAULT 0,
  observaciones TEXT,
  fechaCreacion TEXT,
  estado TEXT DEFAULT 'confirmada',
  FOREIGN KEY(proveedorId) REFERENCES proveedores(id)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS compra_items(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  compraId INTEGER NOT NULL,
  productoId INTEGER NOT NULL,
  productoDescripcion TEXT,
  cantidad INTEGER DEFAULT 0,
  costo REAL DEFAULT 0,
  subtotal REAL DEFAULT 0,
  FOREIGN KEY(compraId) REFERENCES compras(id),
  FOREIGN KEY(productoId) REFERENCES productos(id)
)
''');
  }

  Future<void> _crearTablaListasPrecios(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS listas_precios(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  porcentaje REAL DEFAULT 0,
  activa INTEGER DEFAULT 1,
  orden INTEGER DEFAULT 0
)
''');

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM listas_precios'),
    )!;
    if (count == 0) {
      await db.insert('listas_precios', {
        'nombre': 'Mayorista',
        'porcentaje': 30.0,
        'activa': 1,
        'orden': 0,
      });
      await db.insert('listas_precios', {
        'nombre': 'Minorista',
        'porcentaje': 50.0,
        'activa': 1,
        'orden': 1,
      });
      await db.insert('listas_precios', {
        'nombre': 'Taller',
        'porcentaje': 40.0,
        'activa': 1,
        'orden': 2,
      });
    }
  }

  Future<void> _crearTablaHistorialPrecios(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS historial_precios(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productoId INTEGER NOT NULL,
  fecha TEXT NOT NULL,
  usuario TEXT,
  costoAnterior REAL DEFAULT 0,
  costoNuevo REAL DEFAULT 0,
  motivo TEXT,
  FOREIGN KEY(productoId) REFERENCES productos(id)
)
''');
  }

  Future<void> _agregarColumnasClienteExtendido(Database db) async {
    final columnas = {
      'apellido': "TEXT DEFAULT ''",
      'cuit': "TEXT DEFAULT ''",
      'condicionIva': "TEXT DEFAULT ''",
      'localidad': "TEXT DEFAULT ''",
      'provincia': "TEXT DEFAULT ''",
      'whatsapp': "TEXT DEFAULT ''",
      'saldo': 'REAL DEFAULT 0',
      'limiteCuenta': 'REAL DEFAULT 0',
    };
    for (final entry in columnas.entries) {
      try {
        await db.execute(
          'ALTER TABLE clientes ADD COLUMN ${entry.key} ${entry.value}',
        );
      } catch (_) {
        // column already exists
      }
    }
  }

  Future<void> _agregarColumnasProveedorExtendido(Database db) async {
    final columnas = {
      'contacto': "TEXT DEFAULT ''",
      'cuit': "TEXT DEFAULT ''",
      'whatsapp': "TEXT DEFAULT ''",
      'web': "TEXT DEFAULT ''",
      'condicionesComerciales': "TEXT DEFAULT ''",
      'tiempoEntrega': "TEXT DEFAULT ''",
    };
    for (final entry in columnas.entries) {
      try {
        await db.execute(
          'ALTER TABLE proveedores ADD COLUMN ${entry.key} ${entry.value}',
        );
      } catch (_) {
        // column already exists
      }
    }
  }

  Future<void> _crearTablaUsuarios(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS usuarios(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  usuario TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  rol TEXT DEFAULT 'usuario',
  activo INTEGER DEFAULT 1
)
''');
    // Default admin user
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM usuarios'),
    )!;
    if (count == 0) {
      await db.insert('usuarios', {
        'nombre': 'Administrador',
        'usuario': 'admin',
        // SHA-256 hash of 'admin' — change this password on first login
        'password': '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
        'rol': 'admin',
        'activo': 1,
      });
    }
  }

  Future<void> _crearTablaAuditLog(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS audit_log(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario TEXT NOT NULL,
  accion TEXT NOT NULL,
  detalle TEXT,
  fecha TEXT NOT NULL
)
''');
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

    if (oldVersion < 6) {
      await _crearTablaUsuarios(db);
      await _crearTablaAuditLog(db);
    }

    if (oldVersion < 7) {
      await _crearTablasCompras(db);
    }

    if (oldVersion < 8) {
      await _crearTablaListasPrecios(db);
    }

    if (oldVersion < 9) {
      await _crearTablaHistorialPrecios(db);
    }

    if (oldVersion < 10) {
      await _agregarColumnasClienteExtendido(db);
      await _agregarColumnasProveedorExtendido(db);
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
