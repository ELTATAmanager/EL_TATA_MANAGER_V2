class Remito {
  int? id;

  String numero;
  DateTime fecha;
  String tipo; // 'entrada' o 'salida'
  
  String? proveedorId; // si es entrada
  String? clienteId;   // si es salida
  
  String estado; // 'pendiente', 'confirmado', 'anulado'
  String observaciones;

  double total;

  Remito({
    this.id,
    required this.numero,
    required this.fecha,
    required this.tipo,
    this.proveedorId,
    this.clienteId,
    required this.estado,
    required this.observaciones,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'proveedorId': proveedorId,
      'clienteId': clienteId,
      'estado': estado,
      'observaciones': observaciones,
      'total': total,
    };
  }

  factory Remito.fromMap(Map<String, dynamic> map) {
    return Remito(
      id: map['id'],
      numero: map['numero'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      tipo: map['tipo'] ?? 'entrada',
      proveedorId: map['proveedorId'],
      clienteId: map['clienteId'],
      estado: map['estado'] ?? 'pendiente',
      observaciones: map['observaciones'] ?? '',
      total: (map['total'] ?? 0).toDouble(),
    );
  }

  Remito copyWith({
    int? id,
    String? numero,
    DateTime? fecha,
    String? tipo,
    String? proveedorId,
    String? clienteId,
    String? estado,
    String? observaciones,
    double? total,
  }) {
    return Remito(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      proveedorId: proveedorId ?? this.proveedorId,
      clienteId: clienteId ?? this.clienteId,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      total: total ?? this.total,
    );
  }
}
