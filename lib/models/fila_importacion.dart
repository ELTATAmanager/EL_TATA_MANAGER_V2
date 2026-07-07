enum EstadoFila { nuevo, actualizar, igual, error }

enum VariacionCosto { ninguna, aumentó, bajó, sinCambios }

class FilaImportacion {
  final String codigo;
  final String descripcion;
  final String marca;
  final String categoria;
  final String proveedorNombre;
  final double costo;
  final double precio;
  final int stock;
  final String foto;
  final String observaciones;
  final EstadoFila estado;
  final String errorMensaje;
  final VariacionCosto variacionCosto;
  final double costoAnterior;

  const FilaImportacion({
    required this.codigo,
    required this.descripcion,
    required this.marca,
    required this.categoria,
    required this.proveedorNombre,
    required this.costo,
    required this.precio,
    required this.stock,
    required this.foto,
    required this.observaciones,
    required this.estado,
    this.errorMensaje = '',
    this.variacionCosto = VariacionCosto.ninguna,
    this.costoAnterior = 0,
  });
}
