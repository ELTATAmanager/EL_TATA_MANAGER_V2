class Cliente {
  int? id;

  String nombre;
  String telefono;
  String direccion;
  String observaciones;

  Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "telefono": telefono,
      "direccion": direccion,
      "observaciones": observaciones,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map["id"],
      nombre: map["nombre"] ?? "",
      telefono: map["telefono"] ?? "",
      direccion: map["direccion"] ?? "",
      observaciones: map["observaciones"] ?? "",
    );
  }
}