import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/theme/theme.dart';

/// Fondo opaco del color de la página para textos sin superficie propia.
class SolidBackgroundWidget extends StatelessWidget {
  const SolidBackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: child);
  }
}
