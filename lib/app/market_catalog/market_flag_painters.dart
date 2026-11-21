import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Dibuja la bandera plana de un mercado: solo franjas y campo, sin escudos.
class MarketFlagArt {
  const MarketFlagArt._();

  /// Graba la bandera una sola vez para repintarla por rebanadas.
  static ui.Picture record(Market market, Size size) {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder), size, market);
    return recorder.endRecording();
  }

  static void paint(Canvas canvas, Size size, Market market) {
    if (market == Market.mexico) {
      _paintMexico(canvas, size);
    } else {
      _paintUnitedStates(canvas, size);
    }
    // Contorno fino: la franja blanca no se pierde sobre la tarjeta blanca.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = MarketConfig.flagOutlineWidth
        ..color = AppColors.dashedLine,
    );
  }

  // Tricolor vertical sin escudo nacional.
  static void _paintMexico(Canvas canvas, Size size) {
    const colors = [
      AppColors.flagMexicoGreen,
      AppColors.flagMexicoWhite,
      AppColors.flagMexicoRed,
    ];
    final band = size.width / colors.length;
    for (final (index, color) in colors.indexed) {
      canvas.drawRect(
        Rect.fromLTWH(index * band, 0, band + 0.5, size.height),
        Paint()..color = color,
      );
    }
  }

  // Franjas rojas y blancas con un cantón azul de estrellas simples.
  static void _paintUnitedStates(Canvas canvas, Size size) {
    final stripe = size.height / MarketConfig.usStripeCount;
    for (final index in Iterable<int>.generate(MarketConfig.usStripeCount)) {
      canvas.drawRect(
        Rect.fromLTWH(0, index * stripe, size.width, stripe + 0.5),
        Paint()
          ..color = index.isEven ? AppColors.flagUsRed : AppColors.flagUsWhite,
      );
    }
    final canton = Rect.fromLTWH(
      0,
      0,
      size.width * MarketConfig.usCantonWidthFraction,
      stripe * MarketConfig.usCantonStripes,
    );
    canvas.drawRect(canton, Paint()..color = AppColors.flagUsBlue);
    final cellWidth = canton.width / MarketConfig.usStarColumns;
    final cellHeight = canton.height / MarketConfig.usStarRows;
    final radius =
        math.min(cellWidth, cellHeight) * MarketConfig.usStarRadiusFraction;
    final starPaint = Paint()..color = AppColors.flagUsWhite;
    for (final row in Iterable<int>.generate(MarketConfig.usStarRows)) {
      final isLong = row.isEven;
      final count = isLong
          ? MarketConfig.usStarColumns
          : MarketConfig.usStarColumns - 1;
      for (final column in Iterable<int>.generate(count)) {
        final x = isLong
            ? (column + 0.5) * cellWidth
            : (column + 1) * cellWidth;
        final y = (row + 0.5) * cellHeight;
        canvas.drawPath(_star(Offset(x, y), radius), starPaint);
      }
    }
  }

  // Estrella de cinco puntas.
  static Path _star(Offset center, double radius) {
    final path = Path();
    for (final point in Iterable<int>.generate(10)) {
      final r = point.isEven ? radius : radius * 0.4;
      final angle = -math.pi / 2 + point * math.pi / 5;
      final offset = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      point == 0
          ? path.moveTo(offset.dx, offset.dy)
          : path.lineTo(offset.dx, offset.dy);
    }
    return path..close();
  }
}

/// Bandera ondeando: la imagen grabada se repinta en rebanadas con onda senoidal.
class MarketFlagPainter extends CustomPainter {
  const MarketFlagPainter({
    required this.picture,
    required this.flagSize,
    required this.phase,
  });

  final ui.Picture picture;
  final Size flagSize;

  /// Avance de la onda, de 0 a 1 durante la celebración.
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(
      (size.width - flagSize.width) / 2,
      (size.height - flagSize.height) / 2,
    );
    const slices = MarketConfig.flagWaveSlices;
    final sliceWidth = flagSize.width / slices;
    const headroom = MarketConfig.celebrationFlagWavePadding * 2;
    for (final index in Iterable<int>.generate(slices)) {
      final fraction = index / (slices - 1);
      final angle =
          2 *
          math.pi *
          (MarketConfig.flagWaveCount * fraction -
              phase * MarketConfig.flagWaveTurns);
      // El lado del asta ondea poco y el libre, más.
      final reach = 0.25 + 0.75 * fraction;
      final x = index * sliceWidth;
      final slice = Rect.fromLTWH(
        x,
        -headroom,
        sliceWidth + 0.6,
        flagSize.height + 2 * headroom,
      );
      canvas
        ..save()
        ..clipRect(slice)
        ..translate(0, math.sin(angle) * MarketConfig.flagWaveAmplitude * reach)
        ..drawPicture(picture);
      final shade = math.cos(angle) * reach;
      canvas
        ..drawRect(
          Rect.fromLTWH(x, 0, sliceWidth + 0.6, flagSize.height),
          Paint()
            ..color =
                (shade > 0 ? AppColors.flagWaveLight : AppColors.flagWaveDark)
                    .withValues(
                      alpha: shade.abs() * MarketConfig.flagWaveShadeOpacity,
                    ),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(MarketFlagPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.picture != picture;
}

/// Destellos amarillos y de tinta que brotan y se apagan alrededor de la bandera.
class MarketSparklesPainter extends CustomPainter {
  const MarketSparklesPainter({required this.progress});

  /// Avance de toda la celebración, de 0 a 1.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, extent, start, isYellow) in MarketConfig.sparkles) {
      final local = (progress - start) / MarketConfig.sparkleLifeFraction;
      if (local <= 0 || local >= 1) continue;
      // Crece y se apaga: un pulso suave por destello.
      final pulse = math.sin(math.pi * AppMotion.enter.transform(local));
      final center = Offset(
        (x + 1) / 2 * size.width,
        (y + 1) / 2 * size.height,
      );
      final path = _sparkle(extent * pulse);
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(local * math.pi / 2);
      canvas.drawPath(
        path,
        Paint()..color = isYellow ? AppColors.accent : AppColors.ink,
      );
      if (isYellow) {
        // El contorno de tinta mantiene el amarillo visible sobre fondo claro.
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = MarketConfig.sparkleOutlineWidth
            ..color = AppColors.ink,
        );
      }
      canvas.restore();
    }
  }

  // Destello de cuatro puntas con lados cóncavos.
  Path _sparkle(double radius) {
    final k = radius * 0.15;
    return Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(k, -k, radius, 0)
      ..quadraticBezierTo(k, k, 0, radius)
      ..quadraticBezierTo(-k, k, -radius, 0)
      ..quadraticBezierTo(-k, -k, 0, -radius)
      ..close();
  }

  @override
  bool shouldRepaint(MarketSparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
