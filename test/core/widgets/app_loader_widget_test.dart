import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el GIF de la config con el tamaño de la config', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLoader())),
    );
    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as AssetImage;
    expect(provider.assetName, AssetsConfig.loaderGifPath);
    expect(image.width, UiConfig.loaderSize);
    expect(image.height, UiConfig.loaderSize);
    expect(image.gaplessPlayback, isTrue);
  });
}
