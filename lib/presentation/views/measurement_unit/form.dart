import 'package:flutter/material.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/presentation/viewmodels/measurement_unit_form_vm.dart';
import 'package:provider/provider.dart';

// ============================================================
// 1. Widget principal (Stateless)
// ============================================================
class MeasurementUnitFormView extends StatelessWidget {
  final String _id;
  final FormAction _action;
  const MeasurementUnitFormView({super.key, String? id, FormAction? action})
    : _id = id ?? '',
      _action = action ?? FormAction.show;

  @override
  Widget build(BuildContext ctx) {
    return ChangeNotifierProvider(
      create: (_) => MeasurementUnitFormVm(id: _id, action: _action),
      child: Scaffold(
        appBar: const _AppBar(),
        body: const SingleChildScrollView(padding: EdgeInsets.all(16), child: _FormContent()),
      ),
    );
  }
}

// ============================================================
// 2. AppBar (con Selector para el título)
// ============================================================
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext ctx) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(ctx)),
          title: Text('${action.label}: unidad de medida'),
          actions: [
            if (action == FormAction.show)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => ctx.read<MeasurementUnitFormVm>().action = FormAction.update,
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
  Widget build(BuildContext ctx) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ID (solo visible en update/show)
        _IdField(),
        SizedBox(height: 16),

        // Icono
        _IconSelector(),
        _IconError(),
        SizedBox(height: 16),

        // Símbolo
        _SymbolField(),
        _SymbolError(),
        SizedBox(height: 16),

        // Nombre
        _NameField(),
        _NameError(),
        SizedBox(height: 16),

        // Grupo
        _GroupField(),
        _GroupError(),
        SizedBox(height: 16),

        // Escala
        _ScaleField(),
        _ScaleError(),
        SizedBox(height: 16),

        // Tipo de unidad
        _TypeUnitDropdown(),
        SizedBox(height: 16),

        // ¿Es exacta?
        _ExactSwitch(),
        SizedBox(height: 16),

        // Descripción
        _DescriptionField(),
        _DescriptionError(),
        SizedBox(height: 16),

        // Error global
        _GlobalError(),
        SizedBox(height: 16),

        // Botones de acción (solo en modo show)
        _ActionButtons(),
      ],
    );
  }
}

// ============================================================
// 4. Campo: ID (solo lectura, se sincroniza si el VM lo cambia externamente)
// ============================================================
class _IdField extends StatefulWidget {
  const _IdField();

  @override
  State<_IdField> createState() => _IdFieldState();
}

class _IdFieldState extends State<_IdField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.id,
      builder: (_, id, _) {
        if (id.isEmpty) return const SizedBox.shrink();

        // Sincroniza si el id cambió por fuera (ej: al crear, el repo asigna el id real)
        if (_controller.text != id) _controller.text = id;

        return Selector<MeasurementUnitFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (_, action, _) {
            if (action == FormAction.create) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: _controller,
                  enabled: false,
                  decoration: const InputDecoration(border: OutlineInputBorder(), filled: true),
                ),
                Selector<MeasurementUnitFormVm, String>(
                  selector: (_, vm) => vm.errorId,
                  builder: (_, error, _) {
                    if (error.isEmpty) return const SizedBox.shrink();
                    return _buildErrorText(error);
                  },
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
// 5. Campo: Símbolo
// ============================================================
class _SymbolField extends StatefulWidget {
  const _SymbolField();

  @override
  State<_SymbolField> createState() => _SymbolFieldState();
}

class _SymbolFieldState extends State<_SymbolField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().symbol);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Símbolo *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<MeasurementUnitFormVm>().symbol = v,
              controller: _controller,
              enabled: action != FormAction.show,
              decoration: const InputDecoration(hintText: 'Ej: g, ml, oz', border: OutlineInputBorder()),
            ),
          ],
        );
      },
    );
  }
}

class _SymbolError extends StatelessWidget {
  const _SymbolError();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorSymbol,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 6. Campo: Nombre
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
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<MeasurementUnitFormVm>().name = v,
              controller: _controller,
              enabled: action != FormAction.show,
              decoration: const InputDecoration(hintText: 'Ej: Gramo, Mililitro', border: OutlineInputBorder()),
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
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorName,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 7. Campo: Grupo
// ============================================================
class _GroupField extends StatefulWidget {
  const _GroupField();

  @override
  State<_GroupField> createState() => _GroupFieldState();
}

class _GroupFieldState extends State<_GroupField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().group);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grupo *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<MeasurementUnitFormVm>().group = v,
              controller: _controller,
              enabled: action != FormAction.show,
              decoration: const InputDecoration(hintText: 'Ej: Peso, Volumen', border: OutlineInputBorder()),
            ),
          ],
        );
      },
    );
  }
}

class _GroupError extends StatelessWidget {
  const _GroupError();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorGroup,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 8. Campo: Escala
// ============================================================
class _ScaleField extends StatefulWidget {
  const _ScaleField();

  @override
  State<_ScaleField> createState() => _ScaleFieldState();
}

class _ScaleFieldState extends State<_ScaleField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().scale.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escala *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) {
                context.read<MeasurementUnitFormVm>().scale = double.tryParse(v) ?? 1.0;
              },
              controller: _controller,
              enabled: action != FormAction.show,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '1.0', border: OutlineInputBorder()),
            ),
          ],
        );
      },
    );
  }
}

class _ScaleError extends StatelessWidget {
  const _ScaleError();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorScale,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 9. Dropdown: Tipo de unidad
// ============================================================
class _TypeUnitDropdown extends StatelessWidget {
  const _TypeUnitDropdown();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, TypeUnit>(
      selector: (_, vm) => vm.typeUnit,
      builder: (_, typeUnit, _) {
        return Selector<MeasurementUnitFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (_, action, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo de Unidad', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<TypeUnit>(
                  value: typeUnit,
                  items: TypeUnit.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.name));
                  }).toList(),
                  onChanged: action == FormAction.show
                      ? null
                      : (v) => context.read<MeasurementUnitFormVm>().typeUnit = v!,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
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
// 10. Switch: ¿Es exacta?
// ============================================================
class _ExactSwitch extends StatelessWidget {
  const _ExactSwitch();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, bool>(
      selector: (_, vm) => vm.isExact,
      builder: (_, isExact, _) {
        return Selector<MeasurementUnitFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (_, action, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('¿Es una unidad exacta?', style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: isExact,
                  onChanged: action == FormAction.show
                      ? null
                      : (v) => context.read<MeasurementUnitFormVm>().isExact = v,
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
// 11. Campo: Descripción
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
    _controller = TextEditingController(text: context.read<MeasurementUnitFormVm>().description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => context.read<MeasurementUnitFormVm>().description = v,
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
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorDescription,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 12. Icono: Selector visual
// ============================================================
class _IconSelector extends StatelessWidget {
  const _IconSelector();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, int>(
      selector: (_, vm) => vm.iconId,
      builder: (_, iconId, _) {
        return Selector<MeasurementUnitFormVm, FormAction>(
          selector: (_, vm) => vm.action,
          builder: (_, action, _) {
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
                          : (_) => context.read<MeasurementUnitFormVm>().iconId = iconOption.id,
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
    return Selector<MeasurementUnitFormVm, String>(
      selector: (_, vm) => vm.errorIconId,
      builder: (_, error, _) {
        if (error.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.only(top: 4), child: _buildErrorText(error));
      },
    );
  }
}

// ============================================================
// 13. Error global
// ============================================================
class _GlobalError extends StatelessWidget {
  const _GlobalError();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, String>(
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
// 14. Botones de acción
// ============================================================
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Selector<MeasurementUnitFormVm, FormAction>(
      selector: (_, vm) => vm.action,
      builder: (_, action, __) {
        if (action == FormAction.show) {
          return ElevatedButton.icon(
            onPressed: () => context.read<MeasurementUnitFormVm>().action = FormAction.update,
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          );
        }

        // Modo create/update: botón de guardar
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<MeasurementUnitFormVm>().save(),
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
// 15. Widget helper para errores
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
