import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/domain/domain.dart';

/// Estado de la foto de un modelo.
sealed class PhotoSlot extends Equatable {
  const PhotoSlot();

  @override
  List<Object?> get props => [];
}

/// La foto se está buscando.
class PhotoLoading extends PhotoSlot {
  const PhotoLoading();
}

/// Se encontró la foto.
class PhotoFound extends PhotoSlot {
  const PhotoFound(this.photo);

  final PhotoEntity photo;

  @override
  List<Object?> get props => [photo];
}

/// No hay foto para el modelo.
class PhotoMissing extends PhotoSlot {
  const PhotoMissing();
}

/// La búsqueda falló o se canceló; se puede pedir de nuevo.
class PhotoFailed extends PhotoSlot {
  const PhotoFailed();
}
