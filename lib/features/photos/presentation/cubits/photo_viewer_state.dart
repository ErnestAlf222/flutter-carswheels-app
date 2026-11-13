import 'package:equatable/equatable.dart';

/// Foto que se está viendo en el visor.
class PhotoViewerState extends Equatable {
  const PhotoViewerState({this.currentIndex = 0});

  final int currentIndex;

  @override
  List<Object?> get props => [currentIndex];
}
