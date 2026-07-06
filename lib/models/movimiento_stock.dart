class MovimientoStock {
  int? id;

  int productoId;
  String tipo; // 'entrada', 'salida', 'ajuste'
  int cantidad;
  
  DateTime fecha;
  String? remitoId;
  String motivo;

  MovimientoStock({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.remitoId,
    required this.motivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'remitoId': remitoId,
      'motivo': motivo,
    };
  }

  factory MovimientoStock.fromMap(Map<String, dynamic> map) {
    return MovimientoStock(
      id: map['id'],
      productoId: map['productoId'],
      tipo: map['tipo'] ?? 'entrada',
      cantidad: map['cantidad'] ?? 0,
      fecha: DateTime.parse(map['fecha']),
      remitoId: map['remitoId'],
      motivo: map['motivo'] ?? '',
    );
  }

  MovimientoStock copyWith({
    int? id,
    int? productoId,
    String? tipo,
    int? cantidad,
    DateTime? fecha,
    String? remitoId,
    String? motivo,
  }) {
    return MovimientoStock(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      remitoId: remitoId ?? this.remitoId,
      motivo: motivo ?? this.motivo,
    );
  }
}
