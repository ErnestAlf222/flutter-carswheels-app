import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cars_wheels_app/core/theme/theme.dart';

/// Banda fija del alto del área segura superior: tinta con íconos claros.
///
/// Va como primer sliver de las pantallas cuyo encabezado se va con el scroll,
/// para que el contenido no se vea bajo los íconos de la barra de estado.
class StatusBarBandSliver extends StatelessWidget {
  const StatusBarBandSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StatusBarBandDelegate(
        height: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _StatusBarBandDelegate extends SliverPersistentHeaderDelegate {
  const _StatusBarBandDelegate({required this.height});

  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // El sliver da solo un tope de alto: se fija el alto exacto de la banda.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: SizedBox(
        height: height,
        child: const ColoredBox(color: AppColors.ink),
      ),
    );
  }

  @override
  bool shouldRebuild(_StatusBarBandDelegate oldDelegate) =>
      height != oldDelegate.height;
}
