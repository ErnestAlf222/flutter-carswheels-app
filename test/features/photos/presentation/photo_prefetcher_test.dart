import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';

/// Proveedor de imagen cuya carga siempre falla.
class _FailingImageProvider extends ImageProvider<_FailingImageProvider> {
  @override
  Future<_FailingImageProvider> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImageProvider key,
    ImageDecoderCallback decode,
  ) => throw StateError('falla a propósito');
}

void main() {
  testWidgets('prefetchLarge pide la URL grande y no lanza ante un error', (
    tester,
  ) async {
    final urls = <String>[];
    final prefetcher = PhotoPrefetcher(
      providerFor: (url) {
        urls.add(url);
        return _FailingImageProvider();
      },
    );
    late BuildContext captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    );
    await tester.runAsync(
      () => prefetcher.prefetchLarge(captured, testPhoto()),
    );
    expect(urls, [testPhoto().thumbnailUrl]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('también ignora un proveedor que lanza al construirse', (
    tester,
  ) async {
    final prefetcher = PhotoPrefetcher(
      providerFor: (_) => throw StateError('sin proveedor'),
    );
    late BuildContext captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    );
    await expectLater(
      prefetcher.prefetchLarge(captured, testPhoto()),
      completes,
    );
  });
}
