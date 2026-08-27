import 'package:flutter/material.dart';

class IconOption {
  final int          id;
  final IconData     icon;
  final String       label;
  final List<String> tags;

  const IconOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.tags
  });

  static IconOption? getId(int id) {
    if (IconOption.exists(id)) return all[id];
    return null;
  }
  static List<IconOption> find(String str) {
    var s = removeDiacritics(str.toLowerCase());
    return all.where((x) => 
        x.tags.any((t) => removeDiacritics(t.toLowerCase()).contains(s)) ||
        removeDiacritics(x.label.toLowerCase()).contains(s)
      ).toList();
  }
  static List<IconOption> getManyIds(Iterable<int> ids) {
    List<IconOption> icons = [];
    for (var id in ids) {
      var icon = getId(id);
      if (icon != null) icons.add(icon);
    }
    return icons;
  }

  static bool exists(int id) => id >= 0 && id < all.length;

  static const List<IconOption> all = [
    IconOption(id: 0, icon: Icons.scale, label: 'Balanza', tags: ['peso', 'gramos', 'kilos', 'pesar', 'gramera']),
    IconOption(id: 1, icon: Icons.water_drop, label: 'Gota', tags: ['líquido', 'agua', 'mililitros', 'gotas']),
    IconOption(id: 2, icon: Icons.opacity, label: 'Opacidad', tags: ['líquido', 'aceite', 'densidad']),
    IconOption(id: 3, icon: Icons.local_fire_department, label: 'Fuego', tags: ['calor', 'temperatura', 'cocción', 'llama']),
    IconOption(id: 4, icon: Icons.thermostat, label: 'Termómetro', tags: ['temperatura', 'grados', 'calor', 'frío']),
    IconOption(id: 5, icon: Icons.straighten, label: 'Regla', tags: ['medida', 'longitud', 'centímetros', 'tamaño']),
    IconOption(id: 6, icon: Icons.grain, label: 'Grano', tags: ['sal', 'azúcar', 'arroz', 'pizca', 'sólido']),
    IconOption(id: 7, icon: Icons.egg, label: 'Huevo', tags: ['huevo', 'unidad', 'ingrediente']),
    IconOption(id: 8, icon: Icons.cake, label: 'Pastel', tags: ['torta', 'postre', 'repostería', 'dulce']),
    IconOption(id: 9, icon: Icons.restaurant, label: 'Cubiertos', tags: ['cuchara', 'tenedor', 'porción', 'plato']),
    IconOption(id: 10, icon: Icons.kitchen, label: 'Cocina', tags: ['nevera', 'refrigerador', 'electrodoméstico']),
    IconOption(id: 11, icon: Icons.blender, label: 'Licuadora', tags: ['batidora', 'mezclar', 'licuar']),
    IconOption(id: 12, icon: Icons.local_dining, label: 'Plato servido', tags: ['comida', 'porción', 'ración']),
    IconOption(id: 13, icon: Icons.icecream, label: 'Helado', tags: ['frío', 'postre', 'dulce']),
    IconOption(id: 14, icon: Icons.wine_bar, label: 'Copa de vino', tags: ['líquido', 'bebida', 'copa', 'alcohol']),
    IconOption(id: 15, icon: Icons.local_bar, label: 'Vaso de trago', tags: ['líquido', 'bebida', 'onza', 'coctel']),
    IconOption(id: 16, icon: Icons.science, label: 'Laboratorio', tags: ['exacto', 'preciso', 'gramera', 'medición']),
    IconOption(id: 17, icon: Icons.timer, label: 'Temporizador', tags: ['tiempo', 'minutos', 'segundos', 'reloj']),
    IconOption(id: 18, icon: Icons.coffee, label: 'Taza de café', tags: ['café', 'taza', 'bebida caliente']),
    IconOption(id: 19, icon: Icons.local_cafe, label: 'Bebida caliente', tags: ['café', 'té', 'infusión', 'taza']),
    IconOption(id: 20, icon: Icons.emoji_food_beverage, label: 'Té', tags: ['infusión', 'bebida caliente', 'taza']),
    IconOption(id: 21, icon: Icons.set_meal, label: 'Pescado', tags: ['carne', 'proteína', 'ingrediente']),
    IconOption(id: 22, icon: Icons.bakery_dining, label: 'Panadería', tags: ['pan', 'horneado', 'masa']),
    IconOption(id: 23, icon: Icons.rice_bowl, label: 'Tazón de arroz', tags: ['arroz', 'cereal', 'grano', 'tazón']),
    IconOption(id: 24, icon: Icons.soup_kitchen, label: 'Sopa', tags: ['caldo', 'líquido', 'olla', 'guiso']),
    IconOption(id: 25, icon: Icons.eco, label: 'Hoja', tags: ['hierbas', 'especias', 'orgánico', 'natural']),
    IconOption(id: 26, icon: Icons.grass, label: 'Hierbas', tags: ['especias', 'condimento', 'natural']),
    IconOption(id: 27, icon: Icons.liquor, label: 'Botella', tags: ['líquido', 'aceite', 'vinagre', 'botella']),
    IconOption(id: 28, icon: Icons.local_pizza, label: 'Pizza', tags: ['porción', 'rebanada', 'comida']),
    IconOption(id: 29, icon: Icons.cookie, label: 'Galleta', tags: ['unidad', 'repostería', 'dulce']),
  ];
}

String removeDiacritics(String str) {
  const withAccents = 'áéíóúÁÉÍÓÚñÑüÜ';
  const withoutAccents = 'aeiouAEIOUnNuU';

  var result = str;
  for (var i = 0; i < withAccents.length; i++) {
    result = result.replaceAll(withAccents[i], withoutAccents[i]);
  }
  return result;
}