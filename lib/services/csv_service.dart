import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../models/producto.dart';
import 'comparador_service.dart';
import 'producto_service.dart';

class CsvService {
  final ProductoService produtoService = ProductoService();
  final ComparadorService comparadorService = ComparadorService();

  Future<int> analizarArchivo() async {
    final productos = await leerArchivo();

    if (productos.isEmpty) {
      return 0;
    }

    final existeBase =
        await produtoService.tieneProductos();

    if (!existeBase) {
      await produtoService.insertarLista(productos);
    } else {
      await comparadorService.compararProductos(
        productos,
      );
    }

    return productos.length;
  }

  Future<List<Producto>> leerArchivo() async {
    final resultado =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (resultado == null) {
      return [];
    }

    final archivo =
        File(resultado.files.single.path!);

    final contenido =
        await archivo.readAsString();

    final filas =
        const CsvToListConverter(
      fieldDelimiter: ';',
      shouldParseNumbers: false,
    ).convert(contenido);

    final List<Producto> productos = [];

    for (int i = 1; i < filas.length; i++) {
      final fila = filas[i];

      if (fila.length < 18) {
        continue;
      }

      final codigo =
          fila[0].toString().trim();

      if (codigo.isEmpty) {
        continue;
      }

      productos.add(
        Producto(
          codigo: codigo,
          descripcion:
              fila[1].toString(),
          marca:
              fila[14].toString(),
          categoria: '',
          proveedor: '',
          ubicacion: '',
          stock: 0,
          costo: convertirNumero(
            fila[17].toString(),
          ),
          precio: convertirNumero(
            fila[4].toString(),
          ),
          observaciones: '',
          foto: '',
        ),
      );
    }

    return productos;
  }  double convertirNumero(String valor) {
    valor = valor.trim();

    valor = valor.replaceAll('\$', '');
    valor = valor.replaceAll('"', '');
    valor = valor.replaceAll('.', '');
    valor = valor.replaceAll(',', '.');

    if (valor.isEmpty) {
      return 0;
    }

    return double.tryParse(valor) ?? 0;
  }
}