import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/class_translator_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

List<ModelGroupEntity> _models(int count) => [
  for (int index = 0; index < count; index++)
    ModelGroupEntity(
      name: 'Modelo$index',
      variants: [ModelEntity(name: 'Modelo$index')],
    ),
];

void main() {
  late _MockModelsCubit modelsCubit;
  late MockPhotosCubit photosCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    modelsCubit = _MockModelsCubit();
    photosCubit = buildMockPhotosCubit();
    when(() => modelsCubit.state).thenReturn(const ModelsInitial());
  });

  Widget section(ModelsState state) => MaterialApp(
    home: withClassTranslator(
      MultiBlocProvider(
        providers: [
          BlocProvider<ModelsCubit>.value(value: modelsCubit),
          BlocProvider<PhotosCubit>.value(value: photosCubit),
          BlocProvider<SummariesCubit>.value(value: buildMockSummariesCubit()),
          BlocProvider<BrandLogosCubit>.value(
            value: buildMockBrandLogosCubit(),
          ),
        ],
        child: Scaffold(
          body: SingleChildScrollView(
            child: ModelsSectionWidget(brandName: 'Honda', state: state),
          ),
        ),
      ),
    ),
  );

  testWidgets('initial muestra solo el nombre de la marca', (tester) async {
    await tester.pumpWidget(section(const ModelsInitial()));
    expect(find.text('Honda'), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsNothing);
    expect(find.byType(AppLoader), findsNothing);
    expect(find.textContaining('modelo'), findsNothing);
  });

  testWidgets('loading muestra esqueletos, sin AppLoader ni conteo', (
    tester,
  ) async {
    await tester.pumpWidget(section(const ModelsLoading()));
    expect(find.byType(AppLoader), findsNothing);
    expect(
      find.byType(ModelCardSkeletonWidget),
      findsNWidgets(UiConfig.skeletonCardCount),
    );
    expect(find.textContaining('modelo'), findsNothing);
  });

  ModelsLoaded loaded({
    int total = 3,
    int year = 2026,
    String brand = 'Honda',
    bool isRefreshing = false,
    AppFailure? failure,
  }) => ModelsLoaded(
    groups: _models(total),
    visibleCount: total,
    year: year,
    brand: brand,
    isRefreshing: isRefreshing,
    refreshFailure: failure,
  );

  testWidgets('refrescando atenúa las tarjetas y no muestra loader', (
    tester,
  ) async {
    await tester.pumpWidget(section(loaded(isRefreshing: true)));
    await tester.pumpAndSettle();
    expect(find.byType(AppLoader), findsNothing);
    expect(find.byType(ModelCardWidget), findsNWidgets(3));
    final refreshable = tester.widget<RefreshableContentWidget>(
      find.byType(RefreshableContentWidget),
    );
    expect(refreshable.isRefreshing, isTrue);
  });

  testWidgets('el fallo de refresco muestra mensaje y llama a retry', (
    tester,
  ) async {
    when(() => modelsCubit.retry()).thenAnswer((_) async {});
    await tester.pumpWidget(
      section(loaded(failure: const NetworkFailure('sin red'))),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.refreshFailedLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    verify(() => modelsCubit.retry()).called(1);
  });

  testWidgets('otra marca entra con fundido de columna sin entrada por '
      'tarjeta en la primera página', (tester) async {
    await tester.pumpWidget(section(loaded(brand: 'Honda')));
    await tester.pumpAndSettle();
    expect(find.byType(AnimatedEntryWidget), findsNothing);
    await tester.pumpWidget(section(loaded(brand: 'Audi')));
    await tester.pump();
    // Durante el fundido conviven la lista anterior y la nueva.
    expect(find.byType(AnimatedSwitcher), findsWidgets);
    expect(find.byType(AnimatedEntryWidget), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(ModelCardWidget), findsNWidgets(3));
  });

  testWidgets('las tarjetas añadidas por loadMore conservan su entrada', (
    tester,
  ) async {
    const page = CatalogConfig.defaultPageSize;
    await tester.pumpWidget(
      section(
        ModelsLoaded(
          groups: _models(page + 3),
          visibleCount: page + 3,
          year: 2026,
          brand: 'Honda',
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byType(AnimatedEntryWidget, skipOffstage: false),
      findsNWidgets(3),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('error muestra ErrorStateWidget y reintenta', (tester) async {
    when(() => modelsCubit.retry()).thenAnswer((_) async {});
    await tester.pumpWidget(
      section(
        const ModelsError(
          NetworkFailure('sin red'),
          year: 2020,
          brand: 'Honda',
        ),
      ),
    );
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    verify(() => modelsCubit.retry()).called(1);
  });

  testWidgets('loaded sin modelos muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      section(
        const ModelsLoaded(
          groups: [],
          visibleCount: 0,
          year: 2026,
          brand: 'Honda',
        ),
      ),
    );
    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.text('0 modelos'), findsOneWidget);
  });

  testWidgets('con un modelo el conteo dice 1 modelo', (tester) async {
    await tester.pumpWidget(
      section(
        ModelsLoaded(
          groups: _models(1),
          visibleCount: 1,
          year: 2026,
          brand: 'Honda',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 modelo'), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsOneWidget);
  });

  testWidgets('muestra solo visibleCount tarjetas y el total en el conteo', (
    tester,
  ) async {
    await tester.pumpWidget(
      section(
        ModelsLoaded(
          groups: _models(51),
          visibleCount: 10,
          year: 2026,
          brand: 'Honda',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('51 modelos'), findsOneWidget);
    expect(
      find.byType(ModelCardWidget, skipOffstage: false),
      findsNWidgets(10),
    );
  });
}
