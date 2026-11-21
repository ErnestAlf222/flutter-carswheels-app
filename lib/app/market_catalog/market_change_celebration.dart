import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:cars_wheels_app/app/market_catalog/market_flag_painters.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Celebración breve del cambio de mercado: bandera ondeando, destellos y texto.
///
/// Solo la tarjeta recibe toques (para omitirla); el resto de la pantalla sigue
/// respondiendo y el catálogo recarga debajo sin esperar.
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
  late final ui.Picture _flag;

  static const Size _flagSize = Size(
    MarketConfig.celebrationFlagWidth,
    MarketConfig.celebrationFlagHeight,
  );

  @override
  void initState() {
    super.initState();
    _flag = MarketFlagArt.record(widget.market, _flagSize);
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
    _flag.dispose();
    super.dispose();
  }

  // Un toque en la tarjeta la despide con un fundido rápido.
  void _dismiss() {
    if (_skip.isAnimating || _skip.isCompleted) return;
    _skip.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(
          0,
          MarketConfig.celebrationVerticalAlignment,
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_timeline, _skip]),
          builder: (context, child) {
            final t = _timeline.value;
            final enter = const Interval(
              0,
              MarketConfig.celebrationEnterEnd,
            ).transform(t);
            final exit = const Interval(
              MarketConfig.celebrationExitStart,
              1,
            ).transform(t);
            final exitEase = AppMotion.change.transform(exit);
            final skipEase = AppMotion.enter.transform(_skip.value);
            final leaving = 1 - exitEase;
            final away = 1 - skipEase;
            final scale =
                (MarketConfig.celebrationStartScale +
                    (1 - MarketConfig.celebrationStartScale) *
                        AppMotion.settle.transform(enter)) *
                (1 -
                    (1 - MarketConfig.celebrationEndScale) *
                        (exitEase > skipEase ? exitEase : skipEase));
            return Opacity(
              opacity: (AppMotion.enter.transform(enter) * leaving * away)
                  .clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: _Card(
              flag: _flag,
              flagSize: _flagSize,
              timeline: _timeline,
              title: widget.title,
              body: widget.body,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta blanca con la bandera, los destellos y las dos líneas de texto.
class _Card extends StatelessWidget {
  const _Card({
    required this.flag,
    required this.flagSize,
    required this.timeline,
    required this.title,
    required this.body,
  });

  final ui.Picture flag;
  final Size flagSize;
  final Animation<double> timeline;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    // Una sola región accesible que se anuncia al aparecer.
    return Semantics(
      liveRegion: true,
      label: '$title. $body',
      container: true,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: MarketConfig.celebrationCardWidth,
          padding: const EdgeInsets.all(MarketConfig.celebrationCardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              MarketConfig.celebrationCardRadius,
            ),
            border: Border.all(
              color: AppColors.outline,
              width: UiConfig.cardBorderWidth,
            ),
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Los destellos cubren la tarjeta entera, detrás y alrededor de la bandera.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: timeline,
                    builder: (context, _) => CustomPaint(
                      painter: MarketSparklesPainter(progress: timeline.value),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: timeline,
                    builder: (context, _) => CustomPaint(
                      size: Size(
                        flagSize.width,
                        flagSize.height +
                            2 * MarketConfig.celebrationFlagWavePadding,
                      ),
                      painter: MarketFlagPainter(
                        picture: flag,
                        flagSize: flagSize,
                        phase: timeline.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: MarketConfig.celebrationFlagGap),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
