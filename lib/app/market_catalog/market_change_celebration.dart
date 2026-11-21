import 'package:flutter/material.dart';

import 'package:cars_wheels_app/app/market_catalog/market_eagle_art.dart';
import 'package:cars_wheels_app/app/market_catalog/market_eagle_flight.dart';
import 'package:cars_wheels_app/app/market_catalog/market_notice_content.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Celebración breve del cambio de mercado: un águila que llega y se aleja.
///
/// La capa es transparente: el águila y la píldora de texto se dibujan sobre la
/// pantalla sin velo ni tarjeta. Solo la píldora recibe toques (para omitirla);
/// el resto responde y el catálogo recarga debajo sin esperar.
class MarketChangeCelebration extends StatefulWidget {
  const MarketChangeCelebration({
    super.key,
    required this.market,
    required this.title,
    required this.body,
    required this.onDone,
  });

  final Market market;
  final String title;
  final String body;

  /// Se llama al terminar o al omitir, cuando ya se puede retirar la capa.
  final VoidCallback onDone;

  @override
  State<MarketChangeCelebration> createState() =>
      _MarketChangeCelebrationState();
}

class _MarketChangeCelebrationState extends State<MarketChangeCelebration>
    with TickerProviderStateMixin {
  // Recursos del framework: la línea de tiempo y la salida rápida al omitir.
  late final AnimationController _timeline;
  late final AnimationController _skip;

  @override
  void initState() {
    super.initState();
    _timeline =
        AnimationController(vsync: this, duration: AppMotion.celebration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onDone();
          })
          ..forward();
    _skip = AnimationController(vsync: this, duration: AppMotion.fast)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      });
  }

  @override
  void dispose() {
    _timeline.dispose();
    _skip.dispose();
    super.dispose();
  }

  // Un toque en la píldora lo despide todo con un fundido rápido.
  void _dismiss() {
    if (_skip.isAnimating || _skip.isCompleted) return;
    _skip.forward();
  }

  @override
  Widget build(BuildContext context) {
    final palette = EaglePalette.of(widget.market);
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_timeline, _skip]),
        builder: (context, _) {
          final t = _timeline.value;
          final away = 1 - AppMotion.enter.transform(_skip.value);
          return Opacity(
            opacity: away.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // El águila solo se dibuja: no recibe toques.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: EagleFlight.opacityAt(t),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: MarketEagleFlightPainter(
                            palette: palette,
                            progress: t,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(
                    0,
                    MarketConfig.pillVerticalAlignment,
                  ),
                  child: _PillTransition(
                    progress: t,
                    child: _Pill(
                      flag: widget.market.flag,
                      title: widget.title,
                      body: widget.body,
                      onTap: _dismiss,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Entra y sale con fundido y un desplazamiento corto.
class _PillTransition extends StatelessWidget {
  const _PillTransition({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enter = const Interval(
      MarketConfig.pillEnterStart,
      MarketConfig.pillEnterEnd,
    ).transform(progress);
    final exit = const Interval(
      MarketConfig.pillExitStart,
      MarketConfig.pillExitEnd,
    ).transform(progress);
    final shown = AppMotion.enter.transform(enter) * (1 - exit);
    // Invisible no recibe toques: solo se puede omitir cuando se ve.
    return IgnorePointer(
      ignoring: shown < MarketConfig.pillTouchableFrom,
      child: Opacity(
        opacity: shown.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(
            0,
            (1 - AppMotion.enter.transform(enter) + exit) *
                MarketConfig.pillSlideOffset,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Píldora de tinta con la banderita y las dos líneas de texto.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.flag,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String flag;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Una sola región accesible que se anuncia al aparecer.
    return Semantics(
      liveRegion: true,
      label: '$title. $body',
      container: true,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (width - 2 * MarketConfig.pillSideMargin).clamp(
              0.0,
              MarketConfig.pillMaxWidth,
            ),
          ),
          child: Material(
            color: AppColors.ink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketConfig.noticeRadius),
            ),
            child: MarketNoticeContent(flag: flag, title: title, body: body),
          ),
        ),
      ),
    );
  }
}
