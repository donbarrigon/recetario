import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recetario/data/repositories/import_export_repository.dart';

class ImportExportVm extends ChangeNotifier {
  final ImportExportRepository _repo = ImportExportRepository();

  /// URL del JSON semilla en GitHub. Reemplazar por la URL real del repo.
  static const String seedUrl = 'https://raw.githubusercontent.com/donbarrigon/recetario-seed/main/seed.json';

  bool _isLoading;
  String _errorMessage;
  String _successMessage;

  ImportExportVm() : _isLoading = false, _errorMessage = '', _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  void _resetMessages() {
    _errorMessage = '';
    _successMessage = '';
  }

  Future<void> importFromWeb() async {
    _isLoading = true;
    _resetMessages();
    notifyListeners();

    try {
      var data = await _repo.downloadSeed(seedUrl);
      await _repo.importData(data);
      _successMessage = 'Datos importados correctamente desde la web';
    } catch (e) {
      _errorMessage = 'No se pudo importar desde la web: $e';
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> importFromFile() async {
    _isLoading = true;
    _resetMessages();
    notifyListeners();

    try {
      var files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);

      if (files.isEmpty || files.first.path == null) {
        _isLoading = false;
        notifyListeners();
        return; // el usuario canceló
      }

      var file = File(files.first.path!);
      var content = await file.readAsString();
      var data = _repo.parse(content);
      await _repo.importData(data);
      _successMessage = 'Datos importados correctamente desde el archivo';
    } catch (e) {
      _errorMessage = 'No se pudo importar el archivo: $e';
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> exportToFile() async {
    _isLoading = true;
    _resetMessages();
    notifyListeners();

    try {
      var jsonString = _repo.exportToJsonString();
      var bytes = Uint8List.fromList(utf8.encode(jsonString));

      var path = await FilePicker.saveFile(
        dialogTitle: 'Guardar respaldo de recetas',
        fileName: 'recetario_backup.json',
        bytes: bytes,
      );

      if (path == null) {
        _isLoading = false;
        notifyListeners();
        return; // el usuario canceló
      }

      _successMessage = 'Archivo exportado correctamente';
    } catch (e) {
      _errorMessage = 'No se pudo exportar el archivo: $e';
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }
}
