import 'package:animate_do/animate_do.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({bool disableAnimations = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Scaffold(
        body: Center(child: SkeletonBarWidget(width: 56, height: 10)),
      ),
    ),
  );

  testWidgets('mide lo pedido y usa el color y el radio del tema', (
    tester,
  ) async {
    await tester.pumpWidget(host(disableAnimations: true));
    expect(tester.getSize(find.byType(SkeletonBarWidget)), const Size(56, 10));
    final box = tester.widget<Container>(find.byType(Container));
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.line);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(AppRadii.skeletonBar),
    );
  });

  testWidgets('pulsa de forma continua con la escala de config', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    final pulse = tester.widget<Pulse>(find.byType(Pulse));
    expect(pulse.infinite, isTrue);
    expect(pulse.to, UiConfig.skeletonPulseScale);
    expect(
      pulse.duration,
      const Duration(milliseconds: AnimationConfig.skeletonPulseMilliseconds),
    );
  });

  testWidgets('con disableAnimations no pulsa', (tester) async {
    await tester.pumpWidget(host(disableAnimations: true));
    expect(find.byType(Pulse), findsNothing);
  });
}
