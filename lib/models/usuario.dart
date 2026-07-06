class Usuario {
  int? id;
  String nombre;
  String usuario;
  String password;
  String rol;
  bool activo;

  Usuario({
    this.id,
    required this.nombre,
    required this.usuario,
    required this.password,
    this.rol = 'usuario',
    this.activo = true,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      usuario: map['usuario'] ?? '',
      password: map['password'] ?? '',
      rol: map['rol'] ?? 'usuario',
      activo: (map['activo'] ?? 1) == 1,
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
    };
  }
}
