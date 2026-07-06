class Producto {
  int? id;

  String codigo;
  String descripcion;
  String marca;
  String categoria;
  String proveedor;
  String ubicacion;

  int stock;

  double costo;
  double precio;
  double precio2;
  double precio3;

  String observaciones;
  String foto;

  Producto({
    this.id,
    required this.codigo,
    required this.descripcion,
    required this.marca,
    required this.categoria,
    required this.proveedor,
    required this.ubicacion,
    required this.stock,
    required this.costo,
    required this.precio,
    this.precio2 = 0.0,
    this.precio3 = 0.0,
    required this.observaciones,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'marca': marca,
      'categoria': categoria,
      'proveedor': proveedor,
      'ubicacion': ubicacion,
      'stock': stock,
      'costo': costo,
      'precio': precio,
      'precio2': precio2,
      'precio3': precio3,
      'observaciones': observaciones,
      'foto': foto,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      codigo: map['codigo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      marca: map['marca'] ?? '',
      categoria: map['categoria'] ?? '',
      proveedor: map['proveedor'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      stock: map['stock'] ?? 0,
      costo: (map['costo'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
      precio2: (map['precio2'] ?? 0).toDouble(),
      precio3: (map['precio3'] ?? 0).toDouble(),
      observaciones: map['observaciones'] ?? '',
      foto: map['foto'] ?? '',
    );
  }

  Producto copyWith({
    int? id,
    String? codigo,
    String? descripcion,
    String? marca,
    String? categoria,
    String? proveedor,
    String? ubicacion,
    int? stock,
    double? costo,
    double? precio,
    double? precio2,
    double? precio3,
    String? observaciones,
    String? foto,
  }) {
    return Producto(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      marca: marca ?? this.marca,
      categoria: categoria ?? this.categoria,
      proveedor: proveedor ?? this.proveedor,
      ubicacion: ubicacion ?? this.ubicacion,
      stock: stock ?? this.stock,
      costo: costo ?? this.costo,
      precio: precio ?? this.precio,
      precio2: precio2 ?? this.precio2,
      precio3: precio3 ?? this.precio3,
      observaciones: observaciones ?? this.observaciones,
      foto: foto ?? this.foto,
    );
  }
}