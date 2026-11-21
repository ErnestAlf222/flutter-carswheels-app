import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/app/favorites/favorite_card_cubits.dart';
import 'package:cars_wheels_app/app/favorites/favorite_photo_mapper.dart';
import 'package:cars_wheels_app/app/favorites/favorites_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../support/brand_logos_test_support.dart';
import '../support/class_translator_test_support.dart';
import '../support/favorites_photo_test_support.dart';
import '../support/favorites_test_support.dart';

class _MockResolveSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockResolvePhoto extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancelSummaries extends Mock
    implements CancelPendingSummariesUseCase {}

class _MockCancelPhotos extends Mock implements CancelPendingPhotosUseCase {}

class _MockConnectivity extends MockCubit<ConnectivityState>
    implements ConnectivityCubit {}

// Foto guardada en un archivo real de la carpeta temporal.
class _DiskStore extends FakeFavoritePhotoStore {
  _DiskStore(this.directory);

  final Directory directory;

  @override
  String? pathOf(String fileName) {
    final file = File('${directory.path}/$fileName');
    return file.existsSync() ? file.path : null;
  }
}

// PNG de 1x1 píxel: lo mínimo para que Image.file lo decodifique.
final List<int> _tinyPng = [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0xf8, 0xcf, 0xc0, 0xf0,
  0x1f, 0x00, 0x05, 0x00, 0x01, 0xff, 0x89, 0x99, 0x3d, 0x1d, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
];

final FavoriteCardCubitsFactory _factory = FavoriteCardCubitsFactory(
  createPhotos: () => SnapshotPhotosCubit(
    resolveModelPhoto: _MockResolvePhoto(),
    cancelPendingPhotos: _MockCancelPhotos(),
    keyBuilder: const PhotoKeyBuilder(selector: PhotoCandidateSelector()),
  ),
  createSummaries: () => SnapshotSummariesCubit(
    resolveGroupSummary: _MockResolveSummary(),
    cancelPendingSummaries: _MockCancelSummaries(),
    keyBuilder: const SummaryKeyBuilder(),
  ),
);

void main() {
  late Directory directory;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fav_offline_test');
    await File('${directory.path}/camry.jpg').writeAsBytes(_tinyPng);
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  FavoriteEntity camry({String? localFileName}) => testFavorite(
    snapshot: FavoriteSnapshotEntity(
      label: 'Mediano',
      engineKinds: const ['gasoline'],
      minKmPerLiter: 11,
      maxKmPerLiter: 14,
      variantNames: const ['Camry LE'],
      photo: testFavoritePhoto(localFileName: localFileName),
    ),
  );

  Future<FavoritesCubit> pumpPage(
    WidgetTester tester,
    FavoriteEntity favorite, {
    bool offline = true,
    double textScale = 1.0,
    BrandLogosCubit? logos,
  }) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = buildFavoritesCubit(
      datasource: InMemoryFavoritesDatasource([favorite]),
    );
    addTearDown(cubit.close);
    final connectivity = _MockConnectivity();
    whenListen(
      connectivity,
      const Stream<ConnectivityState>.empty(),
      initialState: ConnectivityState(
        phase: offline ? ConnectionPhase.offline : ConnectionPhase.online,
      ),
    );
    when(() => connectivity.verify()).thenAnswer((_) async {});
    when(() => connectivity.state).thenReturn(
      ConnectivityState(
        phase: offline ? ConnectionPhase.offline : ConnectionPhase.online,
      ),
    );
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<FavoriteCardCubitsFactory>.value(value: _factory),
          RepositoryProvider<FavoritePhotoStore>.value(
            value: _DiskStore(directory),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesCubit>.value(value: cubit),
            BlocProvider<ConnectivityCubit>.value(value: connectivity),
            BlocProvider<BrandLogosCubit>.value(
              value: logos ?? buildMockBrandLogosCubit(),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
            home: withClassTranslator(
              FavoritesPage(
                selectorBuilder: (_) => const SizedBox(width: 160),
                gridBuilder: buildFavoritesGrid,
                onOpen: (_, _) {},
                onExplore: (_) {},
                loadCompareCapacity: (_) async => const {},
                onCompare: (_, _) async => false,
                onGoToCompare: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return cubit;
  }

  testWidgets('sin red la tarjeta muestra la foto del archivo local', (
    tester,
  ) async {
    await pumpPage(tester, camry(localFileName: 'camry.jpg'));
    final local = tester.widget<LocalFirstImageWidget>(
      find.byType(LocalFirstImageWidget),
    );
    expect(local.localPath, endsWith('camry.jpg'));
    // Con cacheWidth la imagen viene envuelta; debajo sigue siendo el archivo.
    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image is ResizeImage
        ? (image.image as ResizeImage).imageProvider
        : image.image;
    expect(provider, isA<FileImage>());
    // La red ni se intenta: no hay imagen de red en la tarjeta.
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con el archivo perdido cae a la referencia de red', (
    tester,
  ) async {
    await pumpPage(tester, camry(localFileName: 'perdido.jpg'));
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('sin archivo local solo se usa la red, como antes', (
    tester,
  ) async {
    await pumpPage(tester, camry());
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('la banda de Favoritos dice que lo guardado está disponible', (
    tester,
  ) async {
    await pumpPage(tester, camry(localFileName: 'camry.jpg'));
    expect(find.text(AppTexts.offlineFavoritesBandLabel), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('sin desbordes a 360 dp y texto a 1.3 sin conexión', (
    tester,
  ) async {
    await pumpPage(tester, camry(localFileName: 'camry.jpg'), textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.text('Camry'), findsWidgets);
  });

  testWidgets(
    'el logo de la marca sale del disco: el cargador lleva su archivo',
    (tester) async {
      final store = _MemoryLogoStore();
      final logos = buildMockBrandLogosCubit(
        urls: {'Toyota': '${LogosConfig.logosBaseUrl}toyota.svg'},
      );
      when(() => logos.fileStore).thenReturn(store);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BrandLogosCubit>.value(
            value: logos,
            child: const Scaffold(
              body: BrandLogoWidget(brandName: 'Toyota', size: 40),
            ),
          ),
        ),
      );
      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final loader = picture.bytesLoader as DiskFirstSvgLoader;
      expect(loader.store, same(store));
      expect(loader.fileName, startsWith('toyota__'));
    },
  );

  group('favoritePhotoEntityOf', () {
    testWidgets('lleva la ruta local solo si el archivo existe', (
      tester,
    ) async {
      late PhotoEntity withFile;
      late PhotoEntity withoutFile;
      await tester.pumpWidget(
        RepositoryProvider<FavoritePhotoStore>.value(
          value: _DiskStore(directory),
          child: Builder(
            builder: (context) {
              withFile = favoritePhotoEntityOf(
                context,
                testFavoritePhoto(localFileName: 'camry.jpg'),
              );
              withoutFile = favoritePhotoEntityOf(
                context,
                testFavoritePhoto(localFileName: 'perdido.jpg'),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(withFile.localPath, endsWith('camry.jpg'));
      expect(withoutFile.localPath, isNull);
      // El crédito CC BY viaja completo con la foto local.
      expect(withFile.authorName, 'Ana');
      expect(withFile.licenseName, 'CC BY-SA 4.0');
      expect(withFile.sourceUrl, 'https://ejemplo.test/origen');
    });

    testWidgets('sin carpeta de fotos solo queda la referencia de red', (
      tester,
    ) async {
      late PhotoEntity photo;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            photo = favoritePhotoEntityOf(
              context,
              testFavoritePhoto(localFileName: 'camry.jpg'),
            );
            return const SizedBox();
          },
        ),
      );
      expect(photo.localPath, isNull);
      expect(photo.thumbnailUrl, isNotEmpty);
    });
  });
}

class _MemoryLogoStore implements LogoFileStore {
  @override
  Future<String?> read(String fileName) async => null;

  @override
  Future<void> write(String fileName, String content) async {}

  @override
  Future<void> discard(String fileName) async {}
}
