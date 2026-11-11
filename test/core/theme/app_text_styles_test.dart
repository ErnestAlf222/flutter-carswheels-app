import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('los títulos y cifras usan Outfit', () {
    final titles = [
      AppTextStyles.screenTitle,
      AppTextStyles.sectionTitle,
      AppTextStyles.cardTitle,
      AppTextStyles.figure,
    ];
    for (final style in titles) {
      expect(style.fontFamily, startsWith('Outfit'));
    }
  });

  test('los textos usan Inter', () {
    final texts = [
      AppTextStyles.body,
      AppTextStyles.bodyStrong,
      AppTextStyles.caption,
      AppTextStyles.label,
    ];
    for (final style in texts) {
      expect(style.fontFamily, startsWith('Inter'));
    }
  });
}
