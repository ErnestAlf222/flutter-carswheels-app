import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App muestra el nombre de la app', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
