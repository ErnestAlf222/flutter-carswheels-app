import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

CompareChartBarEntity _bar(
  int index,
  double? value, {
  bool best = false,
  String? text,
}) => CompareChartBarEntity(
  slotIndex: index,
  value: value,
  valueText: text ?? (value == null ? AppTexts.noDataLabel : '$value'),
  isBest: best,
);

CompareChartMetricEntity _metric(
  List<CompareChartBarEntity> bars, {
  CompareRowKind kind = CompareRowKind.combinedConsumption,
}) => CompareChartMetricEntity(kind: kind, label: 'Métrica', bars: bars);

const List<String> _names = ['Toyota Corolla', 'Toyota Camry', 'Honda Civic'];

CompareChartPainter _painter(
  CompareChartMetricEntity metric, {
  double progress = 1.0,
  TextScaler scaler = TextScaler.noScaling,
}) => CompareChartPainter(
  metric: metric,
  names: _names,
  progress: progress,
  textScaler: scaler,
);

// Lo que se dibuja, con un lienzo que registra las llamadas.
List<Invocation> _draw(CompareChartPainter painter, {double width = 300}) {
  final canvas = TestRecordingCanvas();
  painter.paint(
    canvas,
    Size(width, CompareChartPainter.totalHeight(painter.textScaler)),
  );
  return [for (final call in canvas.invocations) call.invocation];
}

Iterable<Invocation> _named(List<Invocation> calls, Symbol name) =>
    calls.where((call) => call.memberName == name);

// Las columnas nítidas: los rectángulos redondeados sin desenfoque.
Iterable<Invocation> _columns(List<Invocation> calls) => _named(
  calls,
  #drawRRect,
).where((call) => (call.positionalArguments[1] as Paint).maskFilter == null);

// Distancia mínima de un punto a la curva muestreada.
double _distanceToPath(Path path, Offset point) {
  final metric = path.computeMetrics().first;
  final distances = [
    for (double at = 0; at <= metric.length; at += 0.5)
      (metric.getTangentForOffset(at)!.position - point).distance,
  ];
  return distances.reduce((a, b) => a < b ? a : b);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('columnas', () {
    test('una por vehículo con dato y ninguna para los que faltan', () {
      final calls = _draw(
        _painter(_metric([_bar(0, 14.6), _bar(1, null), _bar(2, 16.2)])),
      );
      expect(_columns(calls), hasLength(2));
      // Sin dato tampoco hay nodo: tres círculos (halo, disco y núcleo) por punto.
      expect(_named(calls, #drawCircle), hasLength(6));
    });

    test('la escala es común: el alto sigue el valor', () {
      final calls = _draw(_painter(_metric([_bar(0, 10), _bar(1, 20)])));
      final heights = [
        for (final call in _columns(calls))
          (call.positionalArguments[0] as RRect).height,
      ];
      expect(heights, hasLength(2));
      expect(heights[1] / heights[0], closeTo(2, 0.001));
      expect(heights[1], CompareConfig.chartPlotHeight);
    });

    test('menor-es-mejor destaca la menor con el neón completo', () {
      final metric = _metric([
        _bar(0, 151),
        _bar(1, 120, best: true),
      ], kind: CompareRowKind.co2);
      expect(metric.lowerIsBetter, isTrue);
      final colors = [
        for (final call in _columns(_draw(_painter(metric))))
          (call.positionalArguments[1] as Paint).color.toARGB32(),
      ];
      expect(colors, [
        AppColors.chartNeonDim.toARGB32(),
        AppColors.chartNeon.toARGB32(),
      ]);
    });

    test('con el avance en cero no hay columnas ni nodos', () {
      final calls = _draw(
        _painter(_metric([_bar(0, 10), _bar(1, 20)]), progress: 0),
      );
      expect(_named(calls, #drawRRect), isEmpty);
      expect(_named(calls, #drawCircle), isEmpty);
    });
  });

  group('línea ondeada', () {
    for (final count in [2, 3]) {
      test('con $count vehículos la curva pasa por cada punto', () {
        final bars = [_bar(0, 12), _bar(1, 20), _bar(2, 8)].take(count);
        final points = CompareChartPainter.pointsOf(
          _metric(bars.toList()),
          300,
          TextScaler.noScaling,
        );
        expect(points, hasLength(count));
        final path = CompareChartPainter.curvePath(points);
        for (final point in points) {
          expect(_distanceToPath(path, point), lessThan(0.6));
        }
      });
    }

    test('es suave: no se sale de la altura de los puntos', () {
      final points = CompareChartPainter.pointsOf(
        _metric([_bar(0, 12), _bar(1, 20), _bar(2, 8)]),
        300,
        TextScaler.noScaling,
      );
      final heights = points.map((point) => point.dy);
      final top = heights.reduce((a, b) => a < b ? a : b);
      final bottom = heights.reduce((a, b) => a > b ? a : b);
      final metric = CompareChartPainter.curvePath(points)
          .computeMetrics()
          .first;
      for (double at = 0; at <= metric.length; at += 1) {
        final y = metric.getTangentForOffset(at)!.position.dy;
        expect(y, inInclusiveRange(top - 0.01, bottom + 0.01));
      }
    });

    test(
      'con 2 vehículos sale en S: tangentes horizontales en los extremos',
      () {
        final points = CompareChartPainter.pointsOf(
          _metric([_bar(0, 10), _bar(1, 20)]),
          300,
          TextScaler.noScaling,
        );
        final metric = CompareChartPainter.curvePath(points)
            .computeMetrics()
            .first;
        final start = metric.getTangentForOffset(0)!.vector;
        final end = metric.getTangentForOffset(metric.length)!.vector;
        expect(start.dy.abs(), lessThan(0.01));
        expect(end.dy.abs(), lessThan(0.01));
      },
    );

    test('sin dato no hay punto y la línea conecta solo los que tienen', () {
      final points = CompareChartPainter.pointsOf(
        _metric([_bar(0, 10), _bar(1, null), _bar(2, 20)]),
        300,
        TextScaler.noScaling,
      );
      expect(points, hasLength(2));
      expect(points.first.dx, 50);
      expect(points.last.dx, 250);
      final distances = CompareChartPainter.pointDistances(points);
      expect(distances.first, 0);
      expect(distances.last, greaterThan(200));
    });

    test('se dibuja progresivamente: sin avance no hay trazo', () {
      final metric = _metric([_bar(0, 10), _bar(1, 20)]);
      int strokes(double progress) =>
          _named(_draw(_painter(metric, progress: progress)), #drawPath).length;
      expect(strokes(0.2), 0);
      // Área, dos capas de halo y el trazo nítido.
      expect(strokes(1.0), 4);
    });
  });

  group('repintado', () {
    final metric = _metric([_bar(0, 10), _bar(1, 20)]);

    test('solo cambia con otros datos o con otro avance', () {
      final base = _painter(metric);
      expect(base.shouldRepaint(_painter(metric)), isFalse);
      expect(base.shouldRepaint(_painter(metric, progress: 0.5)), isTrue);
      expect(
        base.shouldRepaint(_painter(_metric([_bar(0, 10), _bar(1, 21)]))),
        isTrue,
      );
    });
  });

  group('widget', () {
    Future<void> pumpChart(
      WidgetTester tester, {
      required double textScale,
      required bool disableAnimations,
    }) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: disableAnimations,
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: Scaffold(
            backgroundColor: AppColors.ink,
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: CompareChartWidget(
                metric: _metric([_bar(0, 14.6), _bar(1, 16.2), _bar(2, 11)]),
                names: const [
                  'Mercedes-Benz Clase C Sedán Híbrido Enchufable 2.0',
                  'Toyota Camry',
                  'Aston Martin DB12 Volante Edición Especial',
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('con disableAnimations el avance es completo', (tester) async {
      await pumpChart(tester, textScale: 1, disableAnimations: true);
      final paint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is CompareChartPainter,
        ),
      );
      expect((paint.painter! as CompareChartPainter).progress, 1.0);
    });

    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'sin desbordes a 360 dp con escala $scale y etiquetas largas',
        (tester) async {
          await pumpChart(tester, textScale: scale, disableAnimations: false);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final size = tester.getSize(find.byType(CompareChartWidget));
          expect(size.width, lessThanOrEqualTo(360));
          expect(
            size.height,
            CompareChartPainter.totalHeight(TextScaler.linear(scale)),
          );
        },
      );
    }
  });
}
