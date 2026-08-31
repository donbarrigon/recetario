import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/presentation/viewmodels/recipe_list_vm.dart';
import 'package:recetario/presentation/views/recipe/form.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class RecipeListView extends StatelessWidget {
  const RecipeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeListVm()..getAll(),
      child: Scaffold(appBar: const _AppBar(), body: const _ListBody(), floatingActionButton: const _CreateFab()),
    );
  }
}

// ============================================================
// 2. AppBar: buscador normalmente, contextual si hay selección
// ============================================================
class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: context.read<RecipeListVm>().query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeListVm, Recipe?>(
      selector: (_, vm) => vm.selected,
      builder: (context, selected, __) {
        if (selected != null) {
          return AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar selección',
              onPressed: () => context.read<RecipeListVm>().clearSelection(),
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
        }

        return AppBar(
          title: TextField(
            controller: _searchController,
            onChanged: (v) => context.read<RecipeListVm>().search(v),
            decoration: const InputDecoration(hintText: 'Buscar receta...', border: InputBorder.none),
          ),
          actions: [
            Selector<RecipeListVm, String>(
              selector: (_, vm) => vm.query,
              builder: (context, query, __) {
                if (query.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: () {
                    _searchController.clear();
                    context.read<RecipeListVm>().search('');
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _open(BuildContext context, Recipe recipe, FormAction action) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeFormView(id: recipe.id, action: action),
      ),
    );
    if (context.mounted) {
      context.read<RecipeListVm>().getAll();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    var vm = context.read<RecipeListVm>();
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Seguro que deseas eliminar "${recipe.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed == true) {
      vm.delete(recipe);
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
          MaterialPageRoute(builder: (_) => const RecipeFormView(action: FormAction.create)),
        );
        if (context.mounted) {
          context.read<RecipeListVm>().getAll();
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
    return Consumer<RecipeListVm>(
      builder: (context, vm, __) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorRecipes.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
                  const SizedBox(height: 8),
                  Text(vm.errorRecipes, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(onPressed: () => vm.getAll(), child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }

        var recipes = vm.recipes;

        if (recipes.isEmpty) {
          return Center(child: Text(vm.query.isEmpty ? 'No hay recetas creadas' : 'Sin resultados para "${vm.query}"'));
        }

        return RefreshIndicator(
          onRefresh: () async => vm.getAll(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: recipes.length,
            itemBuilder: (context, i) => _RecipeTile(recipe: recipes[i]),
          ),
        );
      },
    );
  }
}

// ============================================================
// 5. Item individual
// ============================================================
class _RecipeTile extends StatelessWidget {
  final Recipe recipe;

  const _RecipeTile({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Selector<RecipeListVm, bool>(
      selector: (_, vm) => vm.selected?.id == recipe.id,
      builder: (context, isSelected, __) {
        return ListTile(
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
          title: Text(recipe.name),
          subtitle: Text(
            '${recipe.ingredients.length} ingrediente${recipe.ingredients.length == 1 ? '' : 's'} · '
            '${recipe.steps.length} paso${recipe.steps.length == 1 ? '' : 's'}',
          ),
          trailing: isSelected ? const Icon(Icons.check_circle) : null,
          onTap: () => context.read<RecipeListVm>().select(recipe),
        );
      },
    );
  }
}
