import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Las fuentes van empaquetadas en assets; no se descargan.
  GoogleFonts.config.allowRuntimeFetching = false;
  final isar = await IsarDatabase.open([
    CachedPhotoModelSchema,
    PhotoGalleryCacheModelSchema,
    GroupSummaryCacheModelSchema,
    VehicleDetailCacheModelSchema,
    SafetyRatingsCacheModelSchema,
    RecallsCacheModelSchema,
    SafetyNoMatchCacheModelSchema,
    MexicoCatalogCacheModelSchema,
    MarketPreferenceModelSchema,
    RecentSearchModelSchema,
    CompareSelectionModelSchema,
    FavoriteModelSchema,
    CachedCommonsLogoModelSchema,
  ]);
  runApp(App(dependencies: AppDependencies.withIsar(isar)));
}
