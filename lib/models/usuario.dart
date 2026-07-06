class Usuario {
  int? id;
  String nombre;
  String usuario;
  String password;
  String rol;
  bool activo;
  DateTime? fechaCreacion;
  DateTime? ultimoAcceso;

  Usuario({
    this.id,
    required this.nombre,
    required this.usuario,
    required this.password,
    this.rol = 'empleado',
    this.activo = true,
    this.fechaCreacion,
    this.ultimoAcceso,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      usuario: map['usuario'] ?? '',
      password: map['password'] ?? '',
      rol: map['rol'] ?? 'empleado',
      activo: (map['activo'] ?? 1) == 1,
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'].toString())
          : null,
      ultimoAcceso: map['ultimoAcceso'] != null
          ? DateTime.tryParse(map['ultimoAcceso'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'password': password,
      'rol': rol,
      'activo': activo ? 1 : 0,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
    };
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? usuario,
    String? password,
    String? rol,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      usuario: usuario ?? this.usuario,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}
