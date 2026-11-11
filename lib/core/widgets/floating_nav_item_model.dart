import 'package:flutter/widgets.dart';

/// Datos de un botón del menú flotante.
class FloatingNavItemModel {
  const FloatingNavItemModel({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
