import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(double width) => MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: const DashedDividerWidget()),
      ),
    ),
  );

  testWidgets('ocupa todo el ancho con 1 de grosor', (tester) async {
    await tester.pumpWidget(host(200));
    expect(
      tester.getSize(find.byType(DashedDividerWidget)),
      const Size(200, 1),
    );
  });

  testWidgets('pinta trazos del color y las medidas de config', (tester) async {
    await tester.pumpWidget(host(70));
    final painter = find.descendant(
      of: find.byType(DashedDividerWidget),
      matching: find.byType(CustomPaint),
    );
    // 70 de ancho con trazo 4 y hueco 3: diez trazos completos.
    const step = UiConfig.dashedDashWidth + UiConfig.dashedGapWidth;
    final matcher = paints;
    for (int index = 0; index < 10; index++) {
      matcher.line(
        p1: Offset(index * step, 0.5),
        p2: Offset(index * step + UiConfig.dashedDashWidth, 0.5),
        color: AppColors.dashedLine,
        strokeWidth: 1,
      );
    }
    expect(tester.renderObject(painter.first), matcher);
  });
}
