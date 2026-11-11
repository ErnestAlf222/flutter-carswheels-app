import 'package:equatable/equatable.dart';

/// Estado de visibilidad del menú flotante.
class NavVisibilityState extends Equatable {
  const NavVisibilityState({required this.visible});

  final bool visible;

  @override
  List<Object?> get props => [visible];
}
