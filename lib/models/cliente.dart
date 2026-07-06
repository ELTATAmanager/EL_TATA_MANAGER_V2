class Cliente {
  int? id;

  String nombre;
  String telefono;
  String direccion;
  String observaciones;
  double descuento;

  Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.observaciones,
    this.descuento = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "telefono": telefono,
      "direccion": direccion,
      "observaciones": observaciones,
      "descuento": descuento,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map["id"],
      nombre: map["nombre"] ?? "",
      telefono: map["telefono"] ?? "",
      direccion: map["direccion"] ?? "",
      observaciones: map["observaciones"] ?? "",
      descuento: (map["descuento"] ?? 0).toDouble(),
    );
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? telefono,
    String? direccion,
    String? observaciones,
    double? descuento,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      observaciones: observaciones ?? this.observaciones,
      descuento: descuento ?? this.descuento,
    );
  }
}
