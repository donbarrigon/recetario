import 'package:flutter/material.dart';
import 'package:recetario/presentation/views/recipe/list.dart';
import 'package:recetario/presentation/views/recipe_ingredient/list.dart';
import 'package:recetario/presentation/views/measurement_unit/list.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text('Recetario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Recetas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeListView()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.egg_outlined),
            title: const Text('Ingredientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeIngredientListView()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Unidades de medida'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MeasurementUnitListView()));
            },
          ),
        ],
      ),
    );
  }
}
