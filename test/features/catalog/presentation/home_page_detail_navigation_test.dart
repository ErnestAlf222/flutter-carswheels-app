import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/class_translator_test_support.dart';
import '../../../support/detail_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(<String>[]);
  });

  late List<Object?> pushedExtras;

  Future<void> pumpHome(WidgetTester tester, {required PhotoSlot? slot}) async {
    pushedExtras = [];
    final catalog = _MockCatalogCubit();
    final models = _MockModelsCubit();
    final precache = _MockLogoPrecacheCubit();
    when(() => catalog.state).thenReturn(
      const CatalogLoaded(
        year: 2020,
        availableYears: [2020, 2019],
        brands: [
          BrandEntity(name: 'Toyota'),
          BrandEntity(name: 'Honda'),
        ],
        selectedIndex: 0,
        windowStart: 0,
      ),
    );
    when(() => models.state).thenReturn(
      const ModelsLoaded(
        groups: [
          ModelGroupEntity(
            name: 'Corolla',
            variants: [
              ModelEntity(name: 'Corolla'),
              ModelEntity(name: 'Corolla LE'),
            ],
          ),
          ModelGroupEntity(
            name: 'Camry',
            variants: [ModelEntity(name: 'Camry')],
          ),
        ],
        visibleCount: 2,
        year: 2020,
        brand: 'Toyota',
      ),
    );
    when(() => precache.state).thenReturn(const LogoPrecacheState());
    when(() => precache.precache(any(), any())).thenReturn(null);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => withClassTranslator(
            MultiBlocProvider(
              providers: [
                BlocProvider<CatalogCubit>.value(value: catalog),
                BlocProvider<ModelsCubit>.value(value: models),
                BlocProvider<PhotosCubit>.value(
                  value: buildMockPhotosCubit(
                    slots: {photoKeyFor('Toyota', 'Corolla', 2020): ?slot},
                  ),
                ),
                BlocProvider<SummariesCubit>.value(
                  value: buildMockSummariesCubit(),
                ),
                BlocProvider<BrandLogosCubit>.value(
                  value: buildMockBrandLogosCubit(),
                ),
                BlocProvider<LogoPrecacheCubit>.value(value: precache),
              ],
              child: const HomePage(),
            ),
          ),
        ),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, state) {
            pushedExtras.add(state.extra);
            return const Text('pantalla detalle');
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
  }

  testWidgets('tocar una tarjeta con foto empuja Detalle con sus argumentos', (
    tester,
  ) async {
    final photo = testPhoto();
    await pumpHome(tester, slot: PhotoFound(photo));
    await tester.tap(find.byType(ModelCardWidget).first);
    await tester.pumpAndSettle();
    expect(find.text('pantalla detalle'), findsOneWidget);
    expect(pushedExtras, [
      DetailArgsEntity(
        brand: 'Toyota',
        groupName: 'Corolla',
        year: 2020,
        variantNames: const ['Corolla', 'Corolla LE'],
        photo: photo,
        heroTag: photoKeyFor('Toyota', 'Corolla', 2020),
      ),
    ]);
  });

  testWidgets('sin foto en el slot la foto de los argumentos es nula', (
    tester,
  ) async {
    await pumpHome(tester, slot: const PhotoLoading());
    await tester.tap(find.byType(ModelCardWidget).last);
    await tester.pumpAndSettle();
    final args = pushedExtras.single! as DetailArgsEntity;
    expect(args.groupName, 'Camry');
    expect(args.photo, isNull);
    expect(args.heroTag, photoKeyFor('Toyota', 'Camry', 2020));
  });

  testWidgets('el ModelPhotoWidget de la tarjeta tiene el mismo heroTag', (
    tester,
  ) async {
    await pumpHome(tester, slot: PhotoFound(testPhoto()));
    final photoWidget = tester.widget<ModelPhotoWidget>(
      find
          .descendant(
            of: find.byType(ModelCardWidget).first,
            matching: find.byType(ModelPhotoWidget),
          )
          .first,
    );
    expect(photoWidget.heroTag, photoKeyFor('Toyota', 'Corolla', 2020));
    expect(find.byType(Hero), findsOneWidget);
  });
}
