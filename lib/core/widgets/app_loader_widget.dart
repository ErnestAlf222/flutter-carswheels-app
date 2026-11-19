import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/solid_background_widget.dart';

/// Loader único de la app: un carrito que recorre una carretera fina.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.compact = false});

  /// En línea y pequeño, sin cubrir contenido; si no, tamaño de pantalla completa.
  final bool compact;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  // Estado único: el controlador de la animación (recurso del framework).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: AnimationConfig.loaderCycleMilliseconds,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      // Sin animaciones: el carrito queda quieto, a mitad de camino.
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final trackWidth = compact
        ? UiConfig.loaderCompactTrackWidth
        : UiConfig.loaderTrackWidth;
    final carSize = compact
        ? UiConfig.loaderCompactCarSize
        : UiConfig.loaderCarSize;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AnimationConfig.loaderCurve,
    );
    return Semantics(
      label: AppTexts.loaderSemanticLabel,
      excludeSemantics: true,
      child: Center(
        child: SolidBackgroundWidget(
          child: SizedBox(
            width: trackWidth,
            height: carSize,
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final travel = trackWidth - carSize;
                final left = travel * curved.value;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RoadPainter(progressX: left + carSize / 2),
                      ),
                    ),
                    Positioned(
                      left: left,
                      top: 0,
                      child: Icon(
                        Symbols.directions_car,
                        size: carSize,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Carretera fina en outline con el tramo recorrido en amarillo señal.
class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.progressX});

  final double progressX;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - UiConfig.loaderRoadThickness / 2;
    final road = Paint()
      ..color = AppColors.outline
      ..strokeWidth = UiConfig.loaderRoadThickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    final traveled = Paint()
      ..color = AppColors.accent
      ..strokeWidth = UiConfig.loaderRoadThickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(progressX, y), traveled);
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) =>
      oldDelegate.progressX != progressX;
}
