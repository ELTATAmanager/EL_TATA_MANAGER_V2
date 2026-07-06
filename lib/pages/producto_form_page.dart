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
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final service = ProductoService();

  final codigoController = TextEditingController();
  final descripcionController = TextEditingController();
  final marcaController = TextEditingController();
  final categoriaController = TextEditingController();
  final proveedorController = TextEditingController();
  final stockController = TextEditingController();
  final costoController = TextEditingController();
  final margenController = TextEditingController(text: '0');
  final precioController = TextEditingController();
  final precio2Controller = TextEditingController();
  final precio3Controller = TextEditingController();
  final observacionesController = TextEditingController();

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
      precio2Controller.text = p.precio2.toString();
      precio3Controller.text = p.precio3.toString();
      if (p.costo > 0 && p.precio > 0) {
        margenController.text =
            ((p.precio / p.costo - 1) * 100).toStringAsFixed(1);
      }
      observacionesController.text = p.observaciones;
      foto = p.foto;
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    descripcionController.dispose();
    marcaController.dispose();
    categoriaController.dispose();
    proveedorController.dispose();
    stockController.dispose();
    costoController.dispose();
    margenController.dispose();
    precioController.dispose();
    precio2Controller.dispose();
    precio3Controller.dispose();
    observacionesController.dispose();
    super.dispose();
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

  void recalcularPrecio() {
    final costo = double.tryParse(costoController.text.replaceAll(',', '.')) ?? 0;
    final margen = double.tryParse(margenController.text.replaceAll(',', '.')) ?? 0;
    final precio = costo * (1 + margen / 100);
    precioController.text = precio.toStringAsFixed(2);
  }

  Future<void> guardar() async {
    final producto = Producto(
      id: widget.producto?.id,
      codigo: codigoController.text.trim(),
      descripcion: descripcionController.text.trim(),
      marca: marcaController.text.trim(),
      categoria: categoriaController.text.trim(),
      proveedor: proveedorController.text.trim(),
      ubicacion: "",
      stock: int.tryParse(stockController.text) ?? 0,
      costo: double.tryParse(costoController.text.replaceAll(',', '.')) ?? 0,
      precio: double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0,
      precio2: double.tryParse(precio2Controller.text.replaceAll(',', '.')) ?? 0,
      precio3: double.tryParse(precio3Controller.text.replaceAll(',', '.')) ?? 0,
      observaciones: observacionesController.text.trim(),
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
    TextEditingController controller, {
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null ? "Nuevo producto" : "Editar producto",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            GestureDetector(
              onTap: elegirFoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: foto.isEmpty ? null : FileImage(File(foto)),
                child: foto.isEmpty
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            campo("Código", codigoController),
            campo("Descripción", descripcionController),
            campo("Marca", marcaController),
            campo("Categoría", categoriaController),
            campo("Comprado en", proveedorController),
            campo("Stock", stockController),
            campo(
              "Costo",
              costoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => recalcularPrecio(),
            ),
            campo(
              "Margen (%)",
              margenController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => recalcularPrecio(),
            ),
            campo(
              "Precio Lista 1",
              precioController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            campo(
              "Precio Lista 2",
              precio2Controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            campo(
              "Precio Lista 3",
              precio3Controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            campo("Observaciones", observacionesController),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: guardar,
                icon: const Icon(Icons.save),
                label: const Text("GUARDAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
