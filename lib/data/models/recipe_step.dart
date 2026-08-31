class RecipeStep {
  final String name;
  final String image;
  final String text;
  final List<RecipeStep> steps;

  RecipeStep({required this.name, required this.image, required this.text, List<RecipeStep>? steps})
    : steps = steps ?? [];

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      name: map['name'],
      image: map['image'],
      text: map['text'],
      steps: (map['steps'] as List? ?? []).map((x) => RecipeStep.fromMap(Map<String, dynamic>.from(x))).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'image': image, 'text': text, 'steps': steps.map((x) => x.toMap()).toList()};
  }

  RecipeStep copyWith({String? name, String? image, String? text, List<RecipeStep>? steps}) {
    return RecipeStep(
      name: name ?? this.name,
      image: image ?? this.image,
      text: text ?? this.text,
      steps: steps ?? this.steps,
    );
  }
}
