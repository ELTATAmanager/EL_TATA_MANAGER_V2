class HistorialImportacion {
  final int? id;
  final String proveedorNombre;
  final String fecha;
  final String nombreArchivo;
  final int totalProductos;
  final int nuevos;
  final int actualizados;
  final int ignorados;
  final int errores;
  final double duracionSegundos;

  const HistorialImportacion({
    this.id,
    required this.proveedorNombre,
    required this.fecha,
    required this.nombreArchivo,
    required this.totalProductos,
    required this.nuevos,
    required this.actualizados,
    required this.ignorados,
    required this.errores,
    required this.duracionSegundos,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'proveedorNombre': proveedorNombre,
        'fecha': fecha,
        'nombreArchivo': nombreArchivo,
        'totalProductos': totalProductos,
        'nuevos': nuevos,
        'actualizados': actualizados,
        'ignorados': ignorados,
        'errores': errores,
        'duracionSegundos': duracionSegundos,
      };

  factory HistorialImportacion.fromMap(Map<String, dynamic> map) {
    return HistorialImportacion(
      id: map['id'] as int?,
      proveedorNombre: map['proveedorNombre'] as String? ?? '',
      fecha: map['fecha'] as String? ?? '',
      nombreArchivo: map['nombreArchivo'] as String? ?? '',
      totalProductos: map['totalProductos'] as int? ?? 0,
      nuevos: map['nuevos'] as int? ?? 0,
      actualizados: map['actualizados'] as int? ?? 0,
      ignorados: map['ignorados'] as int? ?? 0,
      errores: map['errores'] as int? ?? 0,
      duracionSegundos: ((map['duracionSegundos'] ?? 0) as num).toDouble(),
    );
  }
}
