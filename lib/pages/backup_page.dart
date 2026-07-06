import 'package:flutter/material.dart';

import '../services/backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final BackupService backupService = BackupService();
  bool procesando = false;

  Future<void> exportarBackup() async {
    setState(() => procesando = true);
    try {
      await backupService.compartirBackup();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup listo para compartir')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar backup: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => procesando = false);
      }
    }
  }

  Future<void> restaurarBackup() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar backup'),
        content: const Text(
          'La app se debe reiniciar después de restaurar. ¿Querés continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => procesando = true);
    try {
      final ok = await backupService.restaurarBackup();
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurado. Reiniciá la app.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar backup: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => procesando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 72,
              child: ElevatedButton.icon(
                onPressed: procesando ? null : exportarBackup,
                icon: const Icon(Icons.backup),
                label: const Text('Exportar / Compartir backup'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: OutlinedButton.icon(
                onPressed: procesando ? null : restaurarBackup,
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar desde archivo'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'El backup es un archivo .db que podés guardar en Google Drive o compartir por WhatsApp',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            if (procesando) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
