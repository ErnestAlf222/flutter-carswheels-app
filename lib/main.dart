import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'core/core.dart';
import 'features/photos/photos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Las fuentes van empaquetadas en assets; no se descargan.
  GoogleFonts.config.allowRuntimeFetching = false;
  final isar = await IsarDatabase.open([CachedPhotoModelSchema]);
  runApp(App(dependencies: AppDependencies.withIsar(isar)));
}
