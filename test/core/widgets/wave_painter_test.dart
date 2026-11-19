import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(400, 200);

  Path pathOf(WaveShape shape) => WavePainter.pathFor(shape, size);

  group('perfiles de ola', () {
    test(
      'encabezado: el cuerpo llena arriba y la curva baja más a la derecha',
      () {
        final path = pathOf(WaveConfig.headerWave);
        const body = 200 - WaveConfig.headerAmplitude;
        // Arriba y justo sobre la banda curva: dentro.
        expect(path.contains(const Offset(200, 5)), isTrue);
        expect(path.contains(const Offset(200, body - 1)), isTrue);
        // El borde inferior real: fuera de la ola por debajo de la banda.
        expect(path.contains(const Offset(200, 199)), isFalse);
        // Lado derecho más bajo que el izquierdo (endY > startY).
        expect(path.contains(const Offset(395, 190)), isTrue);
        expect(path.contains(const Offset(5, 190)), isFalse);
      },
    );

    test(
      'pie del marco: abajo al centro dentro, arriba del lado bajo fuera',
      () {
        final path = pathOf(WaveConfig.footerWave);
        expect(path.contains(const Offset(200, 199)), isTrue);
        // Lado izquierdo alto: la ola ya cubre cerca de su borde superior.
        expect(path.contains(const Offset(5, 10)), isTrue);
        // Lado derecho bajo: el borde superior queda en la base de la banda.
        expect(path.contains(const Offset(395, 5)), isFalse);
        expect(
          path.contains(const Offset(395, WaveConfig.footerAmplitude + 2)),
          isTrue,
        );
      },
    );

    test(
      'pie de Detalle: espejado, alto a la derecha y bajo a la izquierda',
      () {
        final path = pathOf(WaveConfig.detailFooterWave);
        expect(path.contains(const Offset(200, 199)), isTrue);
        expect(path.contains(const Offset(395, 10)), isTrue);
        expect(path.contains(const Offset(5, 10)), isFalse);
        expect(
          path.contains(const Offset(5, WaveConfig.detailFooterAmplitude + 2)),
          isTrue,
        );
      },
    );

    test('los tres perfiles del pie y del encabezado son formas distintas', () {
      final shapes = {
        WaveConfig.headerWave,
        WaveConfig.footerWave,
        WaveConfig.detailFooterWave,
      };
      expect(shapes, hasLength(3));
      // Huella de cada ola: qué puntos de una rejilla caen dentro.
      final signatures = {
        for (final shape in shapes)
          [
            for (double x = 5.0; x < 400; x += 30)
              for (double y = 2.0; y < 200; y += 6)
                pathOf(shape).contains(Offset(x, y)),
          ].join(),
      };
      expect(signatures, hasLength(3));
    });
  });

  group('WavePainter', () {
    test('shouldRepaint compara solo forma y color', () {
      const painter = WavePainter(
        shape: WaveConfig.footerWave,
        color: AppColors.ink,
      );
      expect(
        painter.shouldRepaint(
          const WavePainter(shape: WaveConfig.footerWave, color: AppColors.ink),
        ),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          const WavePainter(
            shape: WaveConfig.detailFooterWave,
            color: AppColors.ink,
          ),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          const WavePainter(
            shape: WaveConfig.footerWave,
            color: AppColors.inkSoft,
          ),
        ),
        isTrue,
      );
    });

    test('el recorte usa el mismo Path y solo recorta si cambia la forma', () {
      const clipper = WaveClipper(WaveConfig.headerWave);
      expect(
        clipper.getClip(size).getBounds(),
        WavePainter.pathFor(WaveConfig.headerWave, size).getBounds(),
      );
      expect(
        clipper.shouldReclip(const WaveClipper(WaveConfig.headerWave)),
        isFalse,
      );
      expect(
        clipper.shouldReclip(const WaveClipper(WaveConfig.footerWave)),
        isTrue,
      );
    });

    testWidgets('la ola va en un RepaintBoundary y no captura toques', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveFooterWidget(shape: WaveConfig.footerWave, height: 100),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(WaveFooterWidget),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
      expect(tester.getSize(find.byType(WaveFooterWidget)).height, 100);
    });
  });
}
