import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Las fuentes van empaquetadas en assets; no se descargan.
  GoogleFonts.config.allowRuntimeFetching = false;
  final isar = await IsarDatabase.open([
    CachedPhotoModelSchema,
    ModelSummaryCacheModelSchema,
  ]);
  runApp(App(dependencies: AppDependencies.withIsar(isar)));
}
