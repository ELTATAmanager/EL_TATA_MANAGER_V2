import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';

class ClienteFormPage extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final ClienteService service = ClienteService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;
  late TextEditingController observacionesController;
  late TextEditingController descuentoController;

  bool guardando = false;

  bool get esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.cliente?.nombre ?? '');
    telefonoController =
        TextEditingController(text: widget.cliente?.telefono ?? '');
    direccionController =
        TextEditingController(text: widget.cliente?.direccion ?? '');
    observacionesController =
        TextEditingController(text: widget.cliente?.observaciones ?? '');
    descuentoController = TextEditingController(
      text: (widget.cliente?.descuento ?? 0).toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    observacionesController.dispose();
    descuentoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => guardando = true);

    final descuento =
        (double.tryParse(descuentoController.text.replaceAll(',', '.')) ?? 0)
            .clamp(0.0, 100.0)
            .toDouble();

    final cliente = Cliente(
      id: widget.cliente?.id,
      nombre: nombreController.text.trim(),
      telefono: telefonoController.text.trim(),
      direccion: direccionController.text.trim(),
      observaciones: observacionesController.text.trim(),
      descuento: descuento,
    );

    if (esEdicion) {
      await service.actualizar(cliente);
    } else {
      await service.insertar(cliente);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar cliente" : "Nuevo cliente"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre *",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Ingresá el nombre" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descuentoController,
                decoration: const InputDecoration(
                  labelText: "Descuento (%)",
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final texto = (value ?? '').trim();
                  if (texto.isEmpty) {
                    return null;
                  }
                  final descuento = double.tryParse(texto.replaceAll(',', '.'));
                  if (descuento == null) {
                    return 'Ingresá un número válido';
                  }
                  if (descuento < 0 || descuento > 100) {
                    return 'El descuento debe estar entre 0 y 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: "Observaciones",
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: guardando ? null : guardar,
                  icon: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(esEdicion ? "ACTUALIZAR" : "GUARDAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
