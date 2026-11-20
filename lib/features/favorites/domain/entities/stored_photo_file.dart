import 'package:equatable/equatable.dart';

/// Un archivo de la carpeta de fotos de favoritos.
class StoredPhotoFile extends Equatable {
  const StoredPhotoFile({required this.name, required this.modified});

  final String name;
  final DateTime modified;

  @override
  List<Object?> get props => [name, modified];
}
