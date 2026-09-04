import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:recetario/presentation/viewmodels/recipe_ingredient_form_vm.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class RecipeIngredientFormView extends StatelessWidget {
  final String _id;
  final FormAction _action;
  const RecipeIngredientFormView({super.key, String? id, FormAction? action})
    : _id = id ?? '',
      _action = action ?? FormAction.show;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeIngredientFormVm(id: _id, action: _action),
      child: Scaffold(
        appBar: const _AppBar(),
        body: const SingleChildScrollView(padding: EdgeInsets.all(16), child: _FormContent()),
      ),
    );
  }
}

// ============================================================
// 2. AppBar
// ============================================================
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (ctx, action, __) {
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(ctx)),
          title: Text('${action.label}: ingrediente'),
          actions: [
            if (action == FormAction.show)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => ctx.read<RecipeIngredientFormVm>().action = FormAction.update,
              ),
          ],
        );
      },
    );
  }
}

// ============================================================
// 3. Contenido del formulario
// ============================================================
class _FormContent extends StatelessWidget {
  const _FormContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NameField(),
        _NameError(),
        SizedBox(height: 16),

        _IconSelector(),
        _IconError(),
        SizedBox(height: 16),

        _MeasureUnitAvailablesField(),
        _MeasureUnitAvailablesError(),
        SizedBox(height: 16),

        _DescriptionField(),
        _DescriptionError(),
        SizedBox(height: 16),

        _GlobalError(),
        SizedBox(height: 16),

        _ActionButtons(),
      ],
    );
  }
}

// ============================================================
// 4. Campo: Nombre
// ============================================================
class _NameField extends StatefulWidget {
  const _NameField();

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<RecipeIngredientFormVm>().name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<RecipeIngredientFormVm>().name = v,
              controller: _controller,
              enabled: action != FormAction.show,
              decoration: const InputDecoration(hintText: 'Ej: Harina, Azúcar', border: OutlineInputBorder()),
            ),
          ],
        );
      },
    );
  }
}

class _NameError extends StatelessWidget {
  const _NameError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, String>(
      selector: (_, vm) => vm.errorName,
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 5. Icono: Selector visual (mismo patrón que MeasurementUnitFormView)
// ============================================================
class _IconSelector extends StatelessWidget {
  const _IconSelector();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, int>(
      selector: (_, vm) => vm.iconId,
      builder: (_, iconId, __) {
        return Selector<RecipeIngredientFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (_, action, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Icono', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: IconOption.all.map((iconOption) {
                    return ChoiceChip(
                      label: Icon(iconOption.icon, size: 24),
                      selected: iconId == iconOption.id,
                      onSelected: action == FormAction.show
                          ? null
                          : (_) => context.read<RecipeIngredientFormVm>().iconId = iconOption.id,
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _IconError extends StatelessWidget {
  const _IconError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, String>(
      selector: (_, vm) => vm.errorIconId,
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 6. Campo: Unidades de medida disponibles (hasMany)
// ============================================================
class _MeasureUnitAvailablesField extends StatelessWidget {
  const _MeasureUnitAvailablesField();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, List<MeasurementUnit>>(
      selector: (_, vm) => vm.measureUnitAvailables,
      builder: (context, available, __) {
        return Selector<RecipeIngredientFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, __) {
            var enabled = action != FormAction.show;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unidades de medida habilitadas *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: enabled ? () => _pickMultiple(context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(border: const OutlineInputBorder(), filled: !enabled),
                    child: available.isEmpty
                        ? const Text('Selecciona las unidades habilitadas')
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: available.map((u) => Chip(label: Text(u.symbol))).toList(),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickMultiple(BuildContext context) async {
    var vm = context.read<RecipeIngredientFormVm>();
    var units = MeasurementUnitRepository().getAll();
    var selectedIds = vm.measureUnitAvailables.map((u) => u.id).toSet();

    var result = await showModalBottomSheet<Set<String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: units.map((u) {
                      return CheckboxListTile(
                        title: Text(u.name),
                        subtitle: Text(u.symbol),
                        value: selectedIds.contains(u.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedIds.add(u.id);
                            } else {
                              selectedIds.remove(u.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx, selectedIds), child: const Text('Listo')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      vm.measureUnitAvailables = units.where((u) => result.contains(u.id)).toList();
    }
  }
}

class _MeasureUnitAvailablesError extends StatelessWidget {
  const _MeasureUnitAvailablesError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, String>(
      selector: (_, vm) => vm.errorMeasureUnitAvailables,
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 7. Campo: Descripción
// ============================================================
class _DescriptionField extends StatefulWidget {
  const _DescriptionField();

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<RecipeIngredientFormVm>().description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<RecipeIngredientFormVm>().description = v,
              controller: _controller,
              enabled: action != FormAction.show,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Descripción opcional (máx 255 caracteres)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DescriptionError extends StatelessWidget {
  const _DescriptionError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, String>(
      selector: (_, vm) => vm.errorDescription,
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 8. Error global
// ============================================================
class _GlobalError extends StatelessWidget {
  const _GlobalError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, String>(
      selector: (_, vm) => vm.errorSave,
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 9. Botones de acción
// ============================================================
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, __) {
        if (action == FormAction.show) {
          return ElevatedButton.icon(
            onPressed: () => context.read<RecipeIngredientFormVm>().action = FormAction.update,
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          );
        }

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<RecipeIngredientFormVm>().save(),
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// 10. Widget helper para errores
// ============================================================
Widget _buildErrorText(String error) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
        ),
      ],
    ),
  );
}
