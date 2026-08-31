import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/models/recipe_ingredient_item.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:recetario/presentation/viewmodels/recipe_form_vm.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class RecipeFormView extends StatelessWidget {
  final String _id;
  final FormAction _action;
  const RecipeFormView({super.key, String? id, FormAction? action})
    : _id = id ?? '',
      _action = action ?? FormAction.show;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeFormVm(id: _id, action: _action),
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
    return Selector<RecipeFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (ctx, action, _) {
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(ctx)),
          title: Text('${action.label}: receta'),
          actions: [
            if (action == FormAction.show)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => ctx.read<RecipeFormVm>().action = FormAction.update,
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

        _DescriptionField(),
        _DescriptionError(),
        SizedBox(height: 16),

        _IngredientsSection(),
        _IngredientsError(),
        SizedBox(height: 16),

        _StepsSection(),
        _StepsError(),
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
    _controller = TextEditingController(text: context.read<RecipeFormVm>().name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<RecipeFormVm>().name = v,
              controller: _controller,
              enabled: action != FormAction.show,
              decoration: const InputDecoration(hintText: 'Ej: Arepas de choclo', border: OutlineInputBorder()),
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
    return Selector<RecipeFormVm, String>(
      selector: (_, vm) => vm.errorName,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 5. Campo: Descripción
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
    _controller = TextEditingController(text: context.read<RecipeFormVm>().description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<RecipeFormVm>().description = v,
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
    return Selector<RecipeFormVm, String>(
      selector: (_, vm) => vm.errorDescription,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 6. Sección: Ingredientes (lista + botón agregar + modal)
// ============================================================
class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, List<RecipeIngredientItem>>(
      selector: (_, vm) => vm.ingredients,
      builder: (context, ingredients, _) {
        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, _) {
            var enabled = action != FormAction.show;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ingredientes *', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (enabled)
                      TextButton.icon(
                        onPressed: () => _showAddIngredientDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                  ],
                ),
                if (ingredients.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sin ingredientes agregados'))
                else
                  ...ingredients.asMap().entries.map((entry) {
                    var index = entry.key;
                    var item = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.ingredient?.name ?? 'Ingrediente desconocido'),
                      subtitle: Text('${item.quantity} ${item.unit?.symbol ?? ''}'),
                      trailing: enabled
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context.read<RecipeFormVm>().removeIngredientAt(index),
                            )
                          : null,
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddIngredientDialog(BuildContext context) async {
    var vm = context.read<RecipeFormVm>();
    var item = await showModalBottomSheet<RecipeIngredientItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddIngredientDialog(),
    );
    if (item != null) {
      vm.addIngredient(item);
    }
  }
}

class _IngredientsError extends StatelessWidget {
  const _IngredientsError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, String>(
      selector: (_, vm) => vm.errorIngredients,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 6b. Modal para agregar un ingrediente (ingrediente + unidad + cantidad)
// ============================================================
class _AddIngredientDialog extends StatefulWidget {
  const _AddIngredientDialog();

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final _repo = RecipeIngredientRepository();
  late final List<RecipeIngredient> _allIngredients;
  RecipeIngredient? _selectedIngredient;
  MeasurementUnit? _selectedUnit;
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _allIngredients = _repo.getAll();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var availableUnits = _selectedIngredient?.measureUnitAvailables ?? [];

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agregar ingrediente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          DropdownButtonFormField<RecipeIngredient>(
            value: _selectedIngredient,
            decoration: const InputDecoration(labelText: 'Ingrediente', border: OutlineInputBorder()),
            items: _allIngredients.map((i) => DropdownMenuItem(value: i, child: Text(i.name))).toList(),
            onChanged: (v) => setState(() {
              _selectedIngredient = v;
              _selectedUnit = null; // cambia el ingrediente, reinicia la unidad elegida
            }),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<MeasurementUnit>(
            value: _selectedUnit,
            decoration: const InputDecoration(labelText: 'Unidad de medida', border: OutlineInputBorder()),
            items: availableUnits
                .map((u) => DropdownMenuItem(value: u, child: Text('${u.name} (${u.symbol})')))
                .toList(),
            onChanged: availableUnits.isEmpty ? null : (v) => setState(() => _selectedUnit = v),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: (_selectedIngredient == null || _selectedUnit == null)
                ? null
                : () {
                    var qty = int.tryParse(_quantityController.text) ?? 0;
                    Navigator.pop(
                      context,
                      RecipeIngredientItem(
                        quantity: qty,
                        unitId: _selectedUnit!.id,
                        unit: _selectedUnit,
                        ingredientId: _selectedIngredient!.id,
                        ingredient: _selectedIngredient,
                      ),
                    );
                  },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 7. Sección: Pasos (lista + botón agregar + modal)
// ============================================================
class _StepsSection extends StatelessWidget {
  const _StepsSection();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, List<RecipeStep>>(
      selector: (_, vm) => vm.steps,
      builder: (context, steps, _) {
        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, _) {
            var enabled = action != FormAction.show;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pasos *', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (enabled)
                      TextButton.icon(
                        onPressed: () => _showAddStepDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                  ],
                ),
                if (steps.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sin pasos agregados'))
                else
                  ...steps.asMap().entries.map((entry) {
                    var index = entry.key;
                    var step = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(step.name),
                      subtitle: Text(step.text.length > 60 ? '${step.text.substring(0, 60)}...' : step.text),
                      trailing: enabled
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context.read<RecipeFormVm>().removeStepAt(index),
                            )
                          : null,
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddStepDialog(BuildContext context) async {
    var vm = context.read<RecipeFormVm>();
    var step = await showModalBottomSheet<RecipeStep>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddStepDialog(),
    );
    if (step != null) {
      vm.addStep(step);
    }
  }
}

class _StepsError extends StatelessWidget {
  const _StepsError();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, String>(
      selector: (_, vm) => vm.errorSteps,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 7b. Modal para agregar un paso (nombre + texto)
// ============================================================
class _AddStepDialog extends StatefulWidget {
  const _AddStepDialog();

  @override
  State<_AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<_AddStepDialog> {
  final _nameController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agregar paso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre del paso', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty || _textController.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                RecipeStep(name: _nameController.text.trim(), image: '', text: _textController.text.trim()),
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
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
    return Selector<RecipeFormVm, String>(
      selector: (_, vm) => vm.errorSave,
      builder: (_, error, _) {
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
    return Selector<RecipeFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        if (action == FormAction.show) {
          return ElevatedButton.icon(
            onPressed: () => context.read<RecipeFormVm>().action = FormAction.update,
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          );
        }

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<RecipeFormVm>().save(),
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
