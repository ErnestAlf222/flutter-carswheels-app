import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la mancha usa el camino de la maqueta y el lienzo de config', () {
    final svg = AppShapes.detailBlobSvg();
    expect(
      svg,
      contains(
        'M70 210C28 130 84 36 186 46C292 56 352 118 332 196C312 274 204 304 '
        '126 284C96 276 78 244 70 210Z',
      ),
    );
    expect(
      svg,
      contains(
        'viewBox="0 0 ${UiConfig.detailBlobCanvasWidth} '
        '${UiConfig.detailBlobCanvasHeight}"',
      ),
    );
  });

  test('el degradado sale de AppColors al 30% de opacidad', () {
    final svg = AppShapes.detailBlobSvg();
    expect(svg, contains('stop-color="#1e40af" stop-opacity="0.3"'));
    expect(svg, contains('stop-color="#0e7490" stop-opacity="0.3"'));
  });

  test('los estilos y radios de Detalle siguen la maqueta', () {
    expect(AppTextStyles.ghostTitle.fontSize, 80);
    expect(AppTextStyles.ghostTitle.letterSpacing, -2);
    expect(AppTextStyles.detailTitle.fontSize, 32);
    expect(AppTextStyles.detailTitle.letterSpacing, -0.3);
    expect(AppTextStyles.statFigure.color, AppColors.link);
    expect(AppTextStyles.infoLabel.color, AppColors.subtle);
    expect(AppRadii.detailPhotoCard, 32);
    expect(AppRadii.versionSelector, 24);
    expect(AppRadii.classChip, 14);
  });
}
