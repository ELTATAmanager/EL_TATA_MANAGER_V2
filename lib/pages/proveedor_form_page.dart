import 'package:flutter/material.dart';

import '../models/proveedor.dart';
import '../services/proveedor_service.dart';

class ProveedorFormPage extends StatefulWidget {
  final Proveedor? proveedor;

  const ProveedorFormPage({
    super.key,
    this.proveedor,
  });

  @override
  State<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends State<ProveedorFormPage> {
  final ProveedorService service = ProveedorService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController emailController;
  late TextEditingController observacionesController;

  bool activo = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.proveedor?.nombre ?? '',
    );
    telefonoController = TextEditingController(
      text: widget.proveedor?.telefono ?? '',
    );
    emailController = TextEditingController(
      text: widget.proveedor?.email ?? '',
    );
    observacionesController = TextEditingController(
      text: widget.proveedor?.observaciones ?? '',
    );

    activo = widget.proveedor?.activo ?? true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    observacionesController.dispose();

    super.dispose();
  }

  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
    });

    try {
      final proveedor = Proveedor(
        id: widget.proveedor?.id,
        nombre: nombreController.text,
        telefono: telefonoController.text,
        email: emailController.text,
        observaciones: observacionesController.text,
        fechaCreacion: widget.proveedor?.fechaCreacion,
        activo: activo,
      );

      if (widget.proveedor == null) {
        await service.insertar(proveedor);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Proveedor guardado exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await service.actualizar(proveedor);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Proveedor actualizado exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proveedor == null ? "Nuevo Proveedor" : "Editar Proveedor",
        ),
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
                  labelText: "Nombre del Proveedor",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El nombre es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El teléfono es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El email es requerido";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Ingrese un email válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: "Observaciones",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Proveedor Activo"),
                value: activo,
                onChanged: (value) {
                  setState(() {
                    activo = value ?? true;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: guardando ? null : guardar,
                  child: guardando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar Proveedor"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
