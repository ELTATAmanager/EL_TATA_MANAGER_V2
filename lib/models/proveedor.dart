class Proveedor {
  int? id;

  String nombre;
  String telefono;
  String email;
  String observaciones;

  DateTime? fechaCreacion;
  bool activo;

  Proveedor({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.email,
    required this.observaciones,
    this.fechaCreacion,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      observaciones: map['observaciones'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : null,
      activo: (map['activo'] ?? 1) == 1,
    );
  }

  Proveedor copyWith({
    int? id,
    String? nombre,
    String? telefono,
    String? email,
    String? observaciones,
    DateTime? fechaCreacion,
    bool? activo,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
    );
  }
}
