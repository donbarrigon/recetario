import 'package:flutter/material.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';

// ============================================================
// 1. Widget principal
// ============================================================
class RecipeDetailView extends StatelessWidget {
  final String id;
  const RecipeDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    var recipe = RecipeRepository().get(id);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receta')),
        body: const Center(child: Text('Esta receta ya no existe.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recipe.description.trim().isNotEmpty)
              _DetailSection(title: 'Descripción', child: Text(recipe.description)),

            _DetailSection(
              title: 'Ingredientes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: recipe.ingredients.map((item) {
                  var iconOption = item.ingredient != null ? IconOption.getId(item.ingredient!.iconId) : null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(child: Icon(iconOption?.icon ?? Icons.help_outline)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.ingredient?.name ?? 'Ingrediente desconocido')),
                        Text(
                          '${item.quantity} ${item.unit?.symbol ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            _DetailSection(
              title: 'Pasos',
              child: Column(
                children: recipe.steps.asMap().entries.map((e) {
                  return _DetailStepNode(step: e.value, path: [e.key]);
                }).toList(),
              ),
            ),

            if (recipe.tips.isNotEmpty)
              _DetailSection(
                title: 'Tips',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.tips.map((t) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 2. Sección colapsable genérica (Descripción / Ingredientes / Pasos / Tips)
// ============================================================
class _DetailSection extends StatefulWidget {
  final String title;
  final Widget child;
  const _DetailSection({required this.title, required this.child});

  @override
  State<_DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<_DetailSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: widget.child),
        ],
      ),
    );
  }
}

// ============================================================
// 3. Nodo de paso de solo lectura: numerado, con sub-pasos expandibles
// ============================================================
class _DetailStepNode extends StatefulWidget {
  final RecipeStep step;
  final List<int> path;
  const _DetailStepNode({required this.step, required this.path});

  @override
  State<_DetailStepNode> createState() => _DetailStepNodeState();
}

class _DetailStepNodeState extends State<_DetailStepNode> {
  bool _expanded = false;

  String get _number => widget.path.map((i) => i + 1).join('.');

  @override
  Widget build(BuildContext context) {
    var hasChildren = widget.step.steps.isNotEmpty;
    var theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: hasChildren ? () => setState(() => _expanded = !_expanded) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_number. ${widget.step.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.step.text),
                      ],
                    ),
                  ),
                  if (hasChildren) Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded && hasChildren)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: widget.step.steps.asMap().entries.map((e) {
                  return _DetailStepNode(step: e.value, path: [...widget.path, e.key]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
