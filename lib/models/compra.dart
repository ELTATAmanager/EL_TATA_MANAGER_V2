class Compra {
  int? id;

  int? proveedorId;
  String proveedorNombre;
  String numero;
  DateTime fecha;
  double total;
  String observaciones;
  DateTime? fechaCreacion;
  String estado; // 'confirmada', 'anulada'

  Compra({
    this.id,
    this.proveedorId,
    required this.proveedorNombre,
    required this.numero,
    required this.fecha,
    required this.total,
    this.observaciones = '',
    this.fechaCreacion,
    this.estado = 'confirmada',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proveedorId': proveedorId,
      'proveedorNombre': proveedorNombre,
      'numero': numero,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'observaciones': observaciones,
      'fechaCreacion': (fechaCreacion ?? DateTime.now()).toIso8601String(),
      'estado': estado,
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      proveedorId: map['proveedorId'],
      proveedorNombre: map['proveedorNombre'] ?? '',
      numero: map['numero'] ?? '',
      fecha: DateTime.tryParse(map['fecha'] ?? '') ?? DateTime.now(),
      total: (map['total'] ?? 0).toDouble(),
      observaciones: map['observaciones'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'])
          : null,
      estado: map['estado'] ?? 'confirmada',
    );
  }

  Compra copyWith({
    int? id,
    int? proveedorId,
    String? proveedorNombre,
    String? numero,
    DateTime? fecha,
    double? total,
    String? observaciones,
    DateTime? fechaCreacion,
    String? estado,
  }) {
    return Compra(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      proveedorNombre: proveedorNombre ?? this.proveedorNombre,
      numero: numero ?? this.numero,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
    );
  }
}
