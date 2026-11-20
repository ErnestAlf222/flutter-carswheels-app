import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorite_burst_painter.dart';

/// Lanza la ráfaga de corazoncitos sobre el centro de [anchorContext].
///
/// Va en el Overlay raíz para no recortarse en los bordes de la tarjeta, y no
/// recibe toques. Se retira sola al terminar. Sin Overlay no hace nada.
void showFavoriteBurst(BuildContext anchorContext) {
  final box = anchorContext.findRenderObject();
  final overlay = Overlay.maybeOf(anchorContext, rootOverlay: true);
  if (box is! RenderBox || !box.attached || overlay == null) return;
  final center = box.localToGlobal(box.size.center(Offset.zero));
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: center.dx - FavoritesConfig.burstBoxSize / 2,
      top: center.dy - FavoritesConfig.burstBoxSize / 2,
      width: FavoritesConfig.burstBoxSize,
      height: FavoritesConfig.burstBoxSize,
      child: IgnorePointer(
        child: ExcludeSemantics(child: _Burst(onDone: () => entry.remove())),
      ),
    ),
  );
  overlay.insert(entry);
}

class _Burst extends StatefulWidget {
  const _Burst({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  // Único estado: el controlador de la ráfaga; al terminar retira su capa.
  late final AnimationController _controller =
      AnimationController(
          vsync: this,
          duration: const Duration(
            milliseconds: FavoritesConfig.burstMilliseconds,
          ),
        )
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        })
        ..forward();
  final List<FavoriteBurstParticle> _particles = favoriteBurstParticles();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: FavoriteBurstPainter(
          progress: _controller.value,
          particles: _particles,
        ),
      ),
    );
  }
}
