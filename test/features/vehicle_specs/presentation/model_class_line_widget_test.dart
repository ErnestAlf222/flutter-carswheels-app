import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/summaries_test_support.dart';

GroupSummaryEntity _summary(String? vehicleClass) => GroupSummaryEntity(
  vehicleClass: vehicleClass,
  minKmPerLiter: 8,
  maxKmPerLiter: 10,
  hasElectric: false,
  hasPluginHybrid: false,
  variantCount: 3,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget line({
    SummarySlot? slot,
    int versions = 3,
    bool disableAnimations = false,
  }) {
    final key = summaryKeyFor('Honda', 'Civic', 2020);
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: BlocProvider<SummariesCubit>.value(
        value: buildMockSummariesCubit(slots: {key: ?slot}),
        child: Scaffold(
          body: ModelClassLineWidget(
            brand: 'Honda',
            groupName: 'Civic',
            year: 2020,
            versionsCount: versions,
          ),
        ),
      ),
    );
  }

  final skeleton = find.byType(SummarySkeletonBarWidget);

  testWidgets('Loading muestra el esqueleto y las versiones', (tester) async {
    await tester.pumpWidget(line(slot: const SummaryLoading()));
    expect(skeleton, findsOneWidget);
    expect(
      tester.getSize(skeleton),
      const Size(
        UiConfig.summarySkeletonLongBarWidth,
        UiConfig.summarySkeletonBarHeight,
      ),
    );
    expect(find.text(AppTexts.versionsCountLabel(3)), findsOneWidget);
  });

  testWidgets('Loading con una versión solo muestra el esqueleto', (
    tester,
  ) async {
    await tester.pumpWidget(line(slot: const SummaryLoading(), versions: 1));
    expect(skeleton, findsOneWidget);
    expect(find.textContaining('versi'), findsNothing);
  });

  testWidgets('Found con clase y versiones usa el separador', (tester) async {
    await tester.pumpWidget(line(slot: SummaryFound(_summary('Midsize Cars'))));
    await tester.pumpAndSettle();
    expect(find.text('Mediano · 3 versiones'), findsOneWidget);
    expect(skeleton, findsNothing);
  });

  testWidgets('Found con clase y una versión muestra solo la clase', (
    tester,
  ) async {
    await tester.pumpWidget(
      line(slot: SummaryFound(_summary('Compact Cars')), versions: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('Compacto'), findsOneWidget);
  });

  testWidgets('Found sin clase muestra solo las versiones', (tester) async {
    await tester.pumpWidget(line(slot: SummaryFound(_summary(null))));
    await tester.pumpAndSettle();
    expect(find.text('3 versiones'), findsOneWidget);
  });

  testWidgets('Missing y Failed muestran solo las versiones', (tester) async {
    await tester.pumpWidget(line(slot: const SummaryMissing()));
    await tester.pumpAndSettle();
    expect(find.text('3 versiones'), findsOneWidget);
    await tester.pumpWidget(line(slot: const SummaryFailed()));
    await tester.pumpAndSettle();
    expect(find.text('3 versiones'), findsOneWidget);
  });

  testWidgets('sin slot muestra solo las versiones', (tester) async {
    await tester.pumpWidget(line());
    await tester.pumpAndSettle();
    expect(find.text('3 versiones'), findsOneWidget);
  });

  testWidgets('sin nada que mostrar no ocupa espacio', (tester) async {
    await tester.pumpWidget(line(slot: const SummaryMissing(), versions: 1));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
    expect(tester.getSize(find.byType(ModelClassLineWidget)).height, 0);
  });

  testWidgets('una clase sin traducir se muestra en inglés sin tracción', (
    tester,
  ) async {
    await tester.pumpWidget(
      line(slot: SummaryFound(_summary('Special Purpose Vehicle 2WD'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Special Purpose Vehicle · 3 versiones'), findsOneWidget);
  });

  testWidgets('la clase entra con fundido', (tester) async {
    await tester.pumpWidget(line(slot: const SummaryLoading()));
    await tester.pumpWidget(line(slot: SummaryFound(_summary('Midsize Cars'))));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: AnimationConfig.fadeDurationMilliseconds),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mediano · 3 versiones'), findsOneWidget);
  });

  testWidgets('con disableAnimations no hay fundido ni pulso', (tester) async {
    await tester.pumpWidget(
      line(slot: const SummaryLoading(), disableAnimations: true),
    );
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
    expect(
      find.descendant(of: skeleton, matching: find.byType(ScaleTransition)),
      findsNothing,
    );
  });
}
