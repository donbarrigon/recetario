import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/presentation/viewmodels/import_export_vm.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class ImportExportView extends StatelessWidget {
  const ImportExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImportExportVm(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Importar / Exportar')),
        body: const _Body(),
      ),
    );
  }
}

// ============================================================
// 2. Cuerpo
// ============================================================
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportExportVm>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Comparte tus recetas con otras personas o descarga un set inicial de recetas, '
                'ingredientes y unidades de medida.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),

              _ActionCard(
                icon: Icons.cloud_download_outlined,
                title: 'Importar desde la web',
                description: 'Descarga un set de recetas, ingredientes y unidades ya establecido.',
                onPressed: vm.isLoading ? null : () => _confirmImport(context, vm.importFromWeb),
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.file_open_outlined,
                title: 'Importar desde archivo',
                description: 'Selecciona un archivo .json que hayas recibido de otra persona.',
                onPressed: vm.isLoading ? null : () => _confirmImport(context, vm.importFromFile),
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.file_download_outlined,
                title: 'Exportar',
                description: 'Crea un archivo .json con todas tus recetas, ingredientes y unidades.',
                onPressed: vm.isLoading ? null : () => vm.exportToFile(),
              ),

              const SizedBox(height: 24),

              if (vm.isLoading) const Center(child: CircularProgressIndicator()),

              if (vm.errorMessage.isNotEmpty) _MessageBanner(message: vm.errorMessage, isError: true),

              if (vm.successMessage.isNotEmpty) _MessageBanner(message: vm.successMessage, isError: false),
            ],
          ),
        );
      },
    );
  }

  /// Las importaciones pueden sobrescribir datos existentes con el mismo id,
  /// así que se confirma antes de proceder.
  Future<void> _confirmImport(BuildContext context, Future<void> Function() action) async {
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Importar datos'),
        content: const Text(
          'Esto puede sobrescribir recetas, ingredientes o unidades de medida que ya tengas '
          'guardados con el mismo id. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Continuar')),
        ],
      ),
    );

    if (confirmed == true) {
      await action();
    }
  }
}

// ============================================================
// 3. Tarjeta de acción reutilizable
// ============================================================
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;

  const _ActionCard({required this.icon, required this.title, required this.description, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: onPressed,
        enabled: onPressed != null,
      ),
    );
  }
}

// ============================================================
// 4. Banner de mensaje (éxito o error)
// ============================================================
class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    var color = isError ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color.shade700)),
          ),
        ],
      ),
    );
  }
}
