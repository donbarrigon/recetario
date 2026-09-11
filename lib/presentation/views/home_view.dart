import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/presentation/viewmodels/home_vm.dart';
import 'package:recetario/presentation/views/recipe_detail_view.dart';
import 'package:recetario/presentation/widgets/components/drawer.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeVm()..getAll(),
      child: Scaffold(appBar: const _AppBar(), drawer: const AppDrawer(), body: const _Body()),
    );
  }
}

// ============================================================
// 2. AppBar con buscador
// ============================================================
class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<HomeVm>().query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _controller,
        onChanged: (v) => context.read<HomeVm>().search(v),
        decoration: const InputDecoration(hintText: 'Buscar recetas, ingredientes, pasos...', border: InputBorder.none),
      ),
      actions: [
        Selector<HomeVm, String>(
          selector: (_, vm) => vm.query,
          builder: (context, query, __) {
            if (query.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar búsqueda',
              onPressed: () {
                _controller.clear();
                context.read<HomeVm>().search('');
              },
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// 3. Cuerpo: grid de 2 columnas
// ============================================================
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeVm>(
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
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, i) => _RecipeCard(recipe: recipes[i]),
          ),
        );
      },
    );
  }
}

// ============================================================
// 4. Card de receta: solo nombre + inicio de descripción
// ============================================================
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailView(id: recipe.id))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                recipe.description,
                style: theme.textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
