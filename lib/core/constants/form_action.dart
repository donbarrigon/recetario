
enum FormAction {
  show,
  create,
  update
}

extension FormactionExtension on FormAction {
  bool isEditable() => this != FormAction.show;
  bool isCreateMode() => this == FormAction.create;
  bool isUpdateMode() => this == FormAction.update;
  bool isShowMode() => this == FormAction.show;

  String get label {
    switch (this) {
      case FormAction.show:
        return 'Ver';
      case FormAction.create:
        return 'Crear';
      case FormAction.update:
        return 'Editar';
    }
  }
}