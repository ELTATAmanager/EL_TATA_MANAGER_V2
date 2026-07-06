import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoFormPage extends StatefulWidget {
  final Producto? producto;

  const ProductoFormPage({
    super.key,
    this.producto,
  });

  @override
  State<ProductoFormPage> createState() =>
      _ProductoFormPageState();
}

class _ProductoFormPageState
    extends State<ProductoFormPage> {
  final service = ProductoService();

  final codigoController = TextEditingController();
  final descripcionController = TextEditingController();
  final marcaController = TextEditingController();
  final categoriaController = TextEditingController();
  final proveedorController = TextEditingController();
  final stockController = TextEditingController();
  final costoController = TextEditingController();
  final precioController = TextEditingController();
  final observacionesController =
      TextEditingController();

  String foto = "";

  @override
  void initState() {
    super.initState();

    if (widget.producto != null) {
      final p = widget.producto!;

      codigoController.text = p.codigo;
      descripcionController.text = p.descripcion;
      marcaController.text = p.marca;
      categoriaController.text = p.categoria;
      proveedorController.text = p.proveedor;
      stockController.text = p.stock.toString();
      costoController.text = p.costo.toString();
      precioController.text = p.precio.toString();
      observacionesController.text =
          p.observaciones;

      foto = p.foto;
    }
  }

  Future<void> elegirFoto() async {
    final picker = ImagePicker();

    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagen == null) return;

    setState(() {
      foto = imagen.path;
    });
  }

  Future<void> guardar() async {
    final producto = Producto(
      id: widget.producto?.id,
      codigo: codigoController.text.trim(),
      descripcion:
          descripcionController.text.trim(),
      marca: marcaController.text.trim(),
      categoria: categoriaController.text.trim(),
      proveedor: proveedorController.text.trim(),
      ubicacion: "",
      stock:
          int.tryParse(stockController.text) ?? 0,
      costo:
          double.tryParse(costoController.text) ??
              0,
      precio:
          double.tryParse(precioController.text) ??
              0,
      observaciones:
          observacionesController.text.trim(),
      foto: foto,
    );

    if (widget.producto == null) {
      await service.insertar(producto);
    } else {
      await service.actualizar(producto);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget campo(
    String titulo,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: titulo,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null
              ? "Nuevo producto"
              : "Editar producto",
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          children: [
            GestureDetector(
              onTap: elegirFoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: foto.isEmpty
                    ? null
                    : FileImage(File(foto)),
                child: foto.isEmpty
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            campo(
              "Código",
              codigoController,
            ),

            campo(
              "Descripción",
              descripcionController,
            ),

            campo(
              "Marca",
              marcaController,
            ),

            campo(
              "Categoría",
              categoriaController,
            ),

            campo(
              "Comprado en",
              proveedorController,
            ),

            campo(
              "Stock",
              stockController,
            ),

            campo(
              "Costo",
              costoController,
            ),

            campo(
              "Precio",
              precioController,
            ),

            campo(
              "Observaciones",
              observacionesController,
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: guardar,
                icon:
                    const Icon(Icons.save),
                label:
                    const Text("GUARDAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}