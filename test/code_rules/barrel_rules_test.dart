import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Archivos .dart de lib/.
Iterable<File> _libFiles() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

/// Ruta con separadores normalizados.
String _norm(String path) => path.replaceAll(r'\', '/');

/// Nombre de la carpeta que contiene el archivo.
String _folderOf(String path) {
  final parts = _norm(path).split('/');
  return parts[parts.length - 2];
}

void main() {
  const maxExports = 30;

  test('todo archivo con export se llama igual que su carpeta', () {
    final offenders = <String>[];
    for (final file in _libFiles()) {
      final hasExport = file.readAsLinesSync().any(
        (l) => l.startsWith('export '),
      );
      if (!hasExport) continue;
      final name = _norm(file.path).split('/').last;
      if (name != '${_folderOf(file.path)}.dart') offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  test('los barriles solo tienen exports, comentarios y blancos', () {
    final offenders = <String>[];
    for (final file in _libFiles()) {
      final lines = file.readAsLinesSync();
      final exportCount = lines.where((l) => l.startsWith('export ')).length;
      if (exportCount == 0) continue;
      final onlyAllowed = lines.every((line) {
        final text = line.trim();
        return text.isEmpty ||
            text.startsWith('//') ||
            text.startsWith('export ');
      });
      if (!onlyAllowed || exportCount > maxExports) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  test('existen los barriles requeridos', () {
    final required = <String>['lib/app/app.dart', 'lib/core/core.dart'];
    final coreDirs = Directory('lib/core').listSync().whereType<Directory>();
    for (final dir in coreDirs) {
      final name = _norm(dir.path).split('/').last;
      required.add('lib/core/$name/$name.dart');
    }
    final featureDirs = Directory('lib/features')
        .listSync()
        .whereType<Directory>();
    for (final dir in featureDirs) {
      final feature = _norm(dir.path).split('/').last;
      final base = 'lib/features/$feature';
      required.add('$base/$feature.dart');
      for (final sub in [
        'domain',
        'infrastructure',
        'presentation/cubits',
        'presentation/blocs',
        'presentation/pages',
        'presentation/widgets',
      ]) {
        if (Directory('$base/$sub').existsSync()) {
          required.add('$base/$sub/${sub.split('/').last}.dart');
        }
      }
    }
    final missing = required.where((p) => !File(p).existsSync()).toList();
    expect(missing, isEmpty);
  });
}
