import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/presentation/viewmodels/recipe_ingredient_list_vm.dart';
import 'package:recetario/presentation/views/recipe_ingredient/form.dart';
import 'package:recetario/core/constants/icon_option.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class RecipeIngredientListView extends StatelessWidget {
  const RecipeIngredientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeIngredientListVm()..getAll(),
      child: Scaffold(appBar: const _AppBar(), body: const _ListBody(), floatingActionButton: const _CreateFab()),
    );
  }
}

// ============================================================
// 2. AppBar contextual
// ============================================================
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeIngredientListVm, RecipeIngredient?>(
      selector: (_, vm) => vm.selected,
      builder: (context, selected, _) {
        if (selected == null) {
          return AppBar(title: const Text('Ingredientes'));
        }

        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar selección',
            onPressed: () => context.read<RecipeIngredientListVm>().clearSelection(),
          ),
          title: Text(selected.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Ver',
              onPressed: () => _open(context, selected, FormAction.show),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => _open(context, selected, FormAction.update),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: () => _confirmDelete(context, selected),
            ),
          ],
        );
      },
    );
  }

  Future<void> _open(BuildContext context, RecipeIngredient ingredient, FormAction action) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeIngredientFormView(id: ingredient.id, action: action),
      ),
    );
    if (context.mounted) {
      context.read<RecipeIngredientListVm>().getAll();
    }
  }

  Future<void> _confirmDelete(BuildContext context, RecipeIngredient ingredient) async {
    var vm = context.read<RecipeIngredientListVm>();
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar ingrediente'),
        content: Text('¿Seguro que deseas eliminar "${ingredient.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed == true) {
      vm.delete(ingredient);
    }
  }
}

// ============================================================
// 3. FAB para crear
// ============================================================
class _CreateFab extends StatelessWidget {
  const _CreateFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecipeIngredientFormView(action: FormAction.create)),
        );
        if (context.mounted) {
          context.read<RecipeIngredientListVm>().getAll();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}

// ============================================================
// 4. Cuerpo de la lista
// ============================================================
class _ListBody extends StatelessWidget {
  const _ListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeIngredientListVm>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorIngredients.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
                  const SizedBox(height: 8),
                  Text(vm.errorIngredients, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(onPressed: () => vm.getAll(), child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }

        if (vm.ingredients.isEmpty) {
          return const Center(child: Text('No hay ingredientes creados'));
        }

        return RefreshIndicator(
          onRefresh: () async => vm.getAll(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: vm.ingredients.length,
            itemBuilder: (context, i) => _IngredientTile(ingredient: vm.ingredients[i]),
          ),
        );
      },
    );
  }
}

// ============================================================
// 5. Item individual — al tocar, selecciona
// ============================================================
class _IngredientTile extends StatelessWidget {
  final RecipeIngredient ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    var iconOption = IconOption.getId(ingredient.iconId);

    return Selector<RecipeIngredientListVm, bool>(
      selector: (_, vm) => vm.selected?.id == ingredient.id,
      builder: (context, isSelected, _) {
        return ListTile(
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          leading: CircleAvatar(child: Icon(iconOption?.icon ?? Icons.help_outline)),
          title: Text(ingredient.name),
          subtitle: Text('${ingredient.measureUnitAvailables?.length ?? 0} unidad(es) de medida habilitada(s)'),
          trailing: isSelected ? const Icon(Icons.check_circle) : null,
          onTap: () => context.read<RecipeIngredientListVm>().select(ingredient),
        );
      },
    );
  }
}
