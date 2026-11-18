import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Pantalla de teléfono muy alta para que la cuadrícula construya todas sus tarjetas.
void useTallPhoneView({double height = 4000}) {
  final view = TestWidgetsFlutterBinding.ensureInitialized()
      .platformDispatcher
      .views
      .first;
  view.physicalSize = Size(390, height);
  view.devicePixelRatio = 1;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}
