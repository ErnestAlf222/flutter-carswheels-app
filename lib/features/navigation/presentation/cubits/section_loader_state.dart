import 'package:equatable/equatable.dart';

/// Estado del aviso ligero al cambiar de sección.
class SectionLoaderState extends Equatable {
  const SectionLoaderState({required this.visible});

  final bool visible;

  @override
  List<Object?> get props => [visible];
}
