import 'package:animate_do/animate_do.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({bool disableAnimations = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Scaffold(
        body: SizedBox(width: 300, child: ModelCardSkeletonWidget()),
      ),
    ),
  );

  testWidgets('se construye y pulsa de forma continua', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.byType(ModelCardSkeletonWidget), findsOneWidget);
    // Cada barra pulsa por su cuenta.
    expect(find.byType(SkeletonBarWidget), findsNWidgets(4));
    expect(find.byType(Pulse), findsNWidgets(4));
    expect(tester.widget<Pulse>(find.byType(Pulse).first).infinite, isTrue);
  });

  testWidgets('con disableAnimations se construye sin pulso', (tester) async {
    await tester.pumpWidget(host(disableAnimations: true));
    await tester.pumpAndSettle();
    expect(find.byType(Pulse), findsNothing);
    expect(find.byType(ModelCardSkeletonWidget), findsOneWidget);
  });

  testWidgets('no expone semántica', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(disableAnimations: true));
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });

  testWidgets('la silueta tiene la foto de 104 por 72', (tester) async {
    await tester.pumpWidget(host(disableAnimations: true));
    await tester.pumpAndSettle();
    final photo = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.constraints?.maxWidth == UiConfig.modelPhotoWidth &&
          widget.constraints?.maxHeight == UiConfig.modelPhotoHeight,
    );
    expect(photo, findsOneWidget);
  });
}
