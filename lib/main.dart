import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';

void main() {
  // Las fuentes van empaquetadas en assets; no se descargan.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const App());
}
