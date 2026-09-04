import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/models/recipe_ingredient_item.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';
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
// 2. AppBar: normal, o contextual cuando hay un paso seleccionado
// ============================================================
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, List<int>?>(
      selector: (_, vm) => vm.selectedStepPath,
      builder: (context, selectedPath, __) {
        if (selectedPath != null) {
          return const _StepContextualAppBar();
        }

        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (ctx, action, __) {
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
      },
    );
  }
}

// ============================================================
// 2b. AppBar contextual del paso seleccionado
// ============================================================
class _StepContextualAppBar extends StatelessWidget {
  const _StepContextualAppBar();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, RecipeStep?>(
      selector: (_, vm) => vm.selectedStep,
      builder: (context, step, __) {
        if (step == null) {
          return AppBar(
            title: const Text('Paso'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<RecipeFormVm>().clearStepSelection(),
            ),
          );
        }

        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar selección',
            onPressed: () => context.read<RecipeFormVm>().clearStepSelection(),
          ),
          title: Text(step.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.subdirectory_arrow_right),
              tooltip: 'Agregar sub-paso',
              onPressed: () => _addSubStep(context),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar paso',
              onPressed: () => _editStep(context, step),
            ),
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Insertar receta como sub-paso',
              onPressed: () => _insertRecipe(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSubStep(BuildContext context) async {
    var vm = context.read<RecipeFormVm>();
    var newStep = await showModalBottomSheet<RecipeStep>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _StepEditDialog(title: 'Agregar sub-paso'),
    );
    if (newStep != null) vm.addSubStepToSelected(newStep);
  }

  Future<void> _editStep(BuildContext context, RecipeStep step) async {
    var vm = context.read<RecipeFormVm>();
    var updated = await showModalBottomSheet<RecipeStep>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StepEditDialog(title: 'Editar paso', initialName: step.name, initialText: step.text),
    );
    if (updated != null) vm.editSelectedStep(name: updated.name, text: updated.text);
  }

  Future<void> _insertRecipe(BuildContext context) async {
    var vm = context.read<RecipeFormVm>();
    var recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecipePickerDialog(excludeId: vm.id),
    );
    if (recipe != null) vm.insertRecipeAsSubStep(recipe);
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
      builder: (_, action, __) {
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
      builder: (_, error, __) {
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
      builder: (_, action, __) {
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
      builder: (_, error, __) {
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
      builder: (context, ingredients, __) {
        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, __) {
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
                    var iconOption = item.ingredient != null ? IconOption.getId(item.ingredient!.iconId) : null;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(iconOption?.icon ?? Icons.help_outline)),
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
      builder: (_, error, __) {
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
              _selectedUnit = null;
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
// 7. Sección: Pasos (árbol expandible + botón agregar raíz)
// ============================================================
class _StepsSection extends StatelessWidget {
  const _StepsSection();

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeFormVm, List<RecipeStep>>(
      selector: (_, vm) => vm.steps,
      builder: (context, steps, __) {
        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, __) {
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
                        onPressed: () => _showAddRootStepDialog(context),
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
                    return _StepNode(step: step, path: [index]);
                  }),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddRootStepDialog(BuildContext context) async {
    var vm = context.read<RecipeFormVm>();
    var step = await showModalBottomSheet<RecipeStep>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _StepEditDialog(title: 'Agregar paso'),
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
      builder: (_, error, __) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 7b. Nodo de paso: expandible, seleccionable, numerado
// ============================================================
class _StepNode extends StatefulWidget {
  final RecipeStep step;
  final List<int> path;

  const _StepNode({required this.step, required this.path});

  @override
  State<_StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<_StepNode> {
  bool _expanded = false;

  String get _number => widget.path.map((i) => i + 1).join('.');

  @override
  Widget build(BuildContext context) {
    var hasChildren = widget.step.steps.isNotEmpty;

    return Selector<RecipeFormVm, bool>(
      selector: (_, vm) => vm.isStepPathSelected(widget.path),
      builder: (context, isSelected, __) {
        return Selector<RecipeFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (context, action, __) {
            var enabled = action != FormAction.show;
            var theme = Theme.of(context);

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: enabled ? () => context.read<RecipeFormVm>().selectStep(widget.path) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 36,
                            child: hasChildren
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                                    onPressed: () => setState(() => _expanded = !_expanded),
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_number. ${widget.step.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  action == FormAction.show || widget.step.text.length <= 60
                                      ? widget.step.text
                                      : '${widget.step.text.substring(0, 60)}...',
                                ),
                              ],
                            ),
                          ),
                          if (enabled)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context.read<RecipeFormVm>().removeStepAtPath(widget.path),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded && hasChildren)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Column(
                        children: widget.step.steps.asMap().entries.map((e) {
                          return _StepNode(step: e.value, path: [...widget.path, e.key]);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// 7c. Modal para agregar/editar un paso (nombre + texto)
// ============================================================
class _StepEditDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialText;

  const _StepEditDialog({required this.title, this.initialName, this.initialText});

  @override
  State<_StepEditDialog> createState() => _StepEditDialogState();
}

class _StepEditDialogState extends State<_StepEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

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
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 7d. Modal para elegir una receta existente (insertar como sub-paso)
// ============================================================
class _RecipePickerDialog extends StatefulWidget {
  final String excludeId;
  const _RecipePickerDialog({required this.excludeId});

  @override
  State<_RecipePickerDialog> createState() => _RecipePickerDialogState();
}

class _RecipePickerDialogState extends State<_RecipePickerDialog> {
  late final List<Recipe> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = RecipeRepository().getAll().where((r) => r.id != widget.excludeId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Selecciona una receta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: _recipes.isEmpty
                ? const Center(child: Text('No hay otras recetas disponibles'))
                : ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, i) {
                      var r = _recipes[i];
                      return ListTile(
                        title: Text(r.name),
                        subtitle: Text('${r.steps.length} paso(s)'),
                        onTap: () => Navigator.pop(context, r),
                      );
                    },
                  ),
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
              Expanded(child: Text(error, style: TextStyle(color: Colors.red.shade700))),
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
      builder: (_, action, __) {
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
        Expanded(child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
      ],
    ),
  );
}