import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Colores de un águila: partes del cuerpo y las tres franjas de acento.
class EaglePalette {
  const EaglePalette({
    required this.body,
    required this.light,
    required this.head,
    required this.tail,
    required this.beak,
    required this.accents,
  });

  /// Águila real con acentos verde, blanco y rojo.
  static const EaglePalette mexico = EaglePalette(
    body: AppColors.eagleGoldenBody,
    light: AppColors.eagleGoldenLight,
    head: AppColors.eagleGoldenCrown,
    tail: AppColors.eagleGoldenBody,
    beak: AppColors.eagleBeak,
    accents: [
      AppColors.flagMexicoGreen,
      AppColors.flagMexicoWhite,
      AppColors.flagMexicoRed,
    ],
  );

  /// Águila calva con acentos rojo, blanco y azul.
  static const EaglePalette unitedStates = EaglePalette(
    body: AppColors.eagleBaldBody,
    light: AppColors.eagleBaldLight,
    head: AppColors.eagleBaldWhite,
    tail: AppColors.eagleBaldWhite,
    beak: AppColors.eagleBeak,
    accents: [AppColors.flagUsRed, AppColors.flagUsWhite, AppColors.flagUsBlue],
  );

  static EaglePalette of(Market market) =>
      market == Market.mexico ? mexico : unitedStates;

  final Color body;
  final Color light;
  final Color head;
  final Color tail;
  final Color beak;
  final List<Color> accents;
}

/// Dibuja un águila genérica en vuelo, de silueta limpia, sin escudos.
///
/// Trabaja en coordenadas unitarias (media envergadura = 1): quien la use
/// traslada y escala el lienzo. [flap] va de 0 (alas arriba) a 1 (alas abajo).
class MarketEagleArt {
  const MarketEagleArt._();

  static void paint(Canvas canvas, EaglePalette palette, double flap) {
    final angle = _lerp(
      EagleArtConfig.wingUpAngle,
      EagleArtConfig.wingDownAngle,
      flap,
    );
    _paintWing(canvas, palette, angle);
    canvas
      ..save()
      ..scale(-1, 1);
    _paintWing(canvas, palette, angle);
    canvas.restore();
    _paintTail(canvas, palette);
    _paintTorso(canvas, palette);
    _paintHead(canvas, palette);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static Offset _point((double, double) value) => Offset(value.$1, value.$2);

  // Gira el punto alrededor del hombro; más cuanto más lejos está de él.
  static Offset _bend(Offset point, double angle) {
    final pivot = _point(EagleArtConfig.wingPivot);
    final reach = ((point.dx - pivot.dx) / EagleArtConfig.wingBendReach).clamp(
      0.0,
      1.0,
    );
    final turn = angle * math.pow(reach, EagleArtConfig.wingBendCurve);
    final r = point - pivot;
    final cosine = math.cos(turn);
    final sine = math.sin(turn);
    return pivot +
        Offset(r.dx * cosine - r.dy * sine, r.dx * sine + r.dy * cosine);
  }

  static Paint _fill(Color color) => Paint()..color = color;

  static Paint _outline() => Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = EagleArtConfig.outlineWidth
    ..color = AppColors.eagleOutline;

  static Path _wingPath(double angle) {
    Offset b((double, double) value) => _bend(_point(value), angle);
    final path = Path()
      ..moveTo(
        b(EagleArtConfig.wingShoulder).dx,
        b(EagleArtConfig.wingShoulder).dy,
      );
    for (final (c1, c2, end) in EagleArtConfig.wingLeadingCurves) {
      path.cubicTo(
        b(c1).dx,
        b(c1).dy,
        b(c2).dx,
        b(c2).dy,
        b(end).dx,
        b(end).dy,
      );
    }
    for (final feather in EagleArtConfig.wingFeatherPoints) {
      path.lineTo(b(feather).dx, b(feather).dy);
    }
    final (control, end) = EagleArtConfig.wingTrailingCurve;
    path
      ..quadraticBezierTo(b(control).dx, b(control).dy, b(end).dx, b(end).dy)
      ..lineTo(b(EagleArtConfig.wingRoot).dx, b(EagleArtConfig.wingRoot).dy)
      ..close();
    return path;
  }

  // Línea horizontal a la altura [y], doblada igual que el ala.
  static Path _bandPath(double y, double angle) {
    final path = Path();
    const segments = EagleArtConfig.accentBandSegments;
    for (final index in Iterable<int>.generate(segments + 1)) {
      final x = _lerp(
        EagleArtConfig.accentBandStartX,
        EagleArtConfig.accentBandEndX,
        index / segments,
      );
      final point = _bend(Offset(x, y), angle);
      index == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  static void _paintWing(Canvas canvas, EaglePalette palette, double angle) {
    final wing = _wingPath(angle);
    canvas
      ..drawPath(wing, _fill(palette.body))
      ..save()
      ..clipPath(wing)
      ..drawPath(
        _bandPath(EagleArtConfig.wingPatchY, angle),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = EagleArtConfig.wingPatchWidth
          ..color = palette.light,
      );
    for (final (index, color) in palette.accents.indexed) {
      canvas.drawPath(
        _bandPath(EagleArtConfig.accentBandOffsets[index], angle),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = EagleArtConfig.accentBandWidth
          ..color = color,
      );
    }
    canvas
      ..restore()
      ..drawPath(wing, _outline());
  }

  static void _paintTail(Canvas canvas, EaglePalette palette) {
    const points = EagleArtConfig.tailPoints;
    final path = Path()..moveTo(points.first.$1, points.first.$2);
    for (final point in points.skip(1)) {
      path.lineTo(point.$1, point.$2);
    }
    path.close();
    canvas
      ..drawPath(path, _fill(palette.tail))
      ..drawPath(path, _outline());
  }

  static void _paintTorso(Canvas canvas, EaglePalette palette) {
    const left = EagleArtConfig.torsoLeftCurve;
    const right = EagleArtConfig.torsoRightCurve;
    final neck = _point(EagleArtConfig.torsoNeckLeft);
    final base = _point(EagleArtConfig.torsoBaseRight);
    final path = Path()
      ..moveTo(neck.dx, neck.dy)
      ..cubicTo(
        left.$1.$1,
        left.$1.$2,
        left.$2.$1,
        left.$2.$2,
        left.$3.$1,
        left.$3.$2,
      )
      ..lineTo(base.dx, base.dy)
      ..cubicTo(
        right.$1.$1,
        right.$1.$2,
        right.$2.$1,
        right.$2.$2,
        right.$3.$1,
        right.$3.$2,
      )
      ..close();
    canvas.drawPath(path, _fill(palette.body));
    // Arcos de plumas del pecho.
    final feather = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = EagleArtConfig.outlineWidth * 0.8
      ..color = palette.light;
    for (final (x, y, width, height) in EagleArtConfig.chestArcs) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, y), width: width, height: height),
        0.2,
        math.pi - 0.4,
        false,
        feather,
      );
    }
    canvas.drawPath(path, _outline());
  }

  static void _paintHead(Canvas canvas, EaglePalette palette) {
    final center = _point(EagleArtConfig.headCenter);
    canvas
      ..drawCircle(center, EagleArtConfig.headRadius, _fill(palette.head))
      ..drawCircle(center, EagleArtConfig.headRadius, _outline());
    const top = EagleArtConfig.beakTopCurve;
    const bottom = EagleArtConfig.beakBottomCurve;
    final start = _point(EagleArtConfig.beakStart);
    final end = _point(EagleArtConfig.beakEnd);
    final beak = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        top.$1.$1,
        top.$1.$2,
        top.$2.$1,
        top.$2.$2,
        top.$3.$1,
        top.$3.$2,
      )
      ..cubicTo(
        bottom.$1.$1,
        bottom.$1.$2,
        bottom.$2.$1,
        bottom.$2.$2,
        bottom.$3.$1,
        bottom.$3.$2,
      )
      ..lineTo(end.dx, end.dy)
      ..close();
    canvas
      ..drawPath(beak, _fill(palette.beak))
      ..drawPath(beak, _outline())
      ..drawCircle(
        _point(EagleArtConfig.eyeCenter),
        EagleArtConfig.eyeRadius,
        _fill(AppColors.eagleOutline),
      )
      ..drawLine(
        _point(EagleArtConfig.browStart),
        _point(EagleArtConfig.browEnd),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = EagleArtConfig.browWidth
          ..color = AppColors.eagleOutline,
      );
  }
}
