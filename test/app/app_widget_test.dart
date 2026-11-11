import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(const App());
    // Deja pasar el tiempo mínimo del loader para no dejar temporizadores.
    await tester.pump(
      const Duration(milliseconds: UiConfig.loaderMinimumVisibleMilliseconds),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.brandsSectionTitle), findsOneWidget);
  });
}
