import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

const String _civic =
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/'
    '2020_Honda_Civic_sedan_au_SIAM_2020.jpg/960px-'
    '2020_Honda_Civic_sedan_au_SIAM_2020.jpg'
    '?utm_source=commons.wikimedia.org&utm_campaign=imageinfo';
const String _brz =
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/96/'
    'Subaru_BRZ_%2C_Toronto.jpg/960px-Subaru_BRZ_%2C_Toronto.jpg';
const String _f150 =
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1d/'
    'Leimershof_US-Car-Treffen_Ford_F-150-20220911-RM-161830.jpg/'
    '960px-Leimershof_US-Car-Treffen_Ford_F-150-20220911-RM-161830.jpg';

void main() {
  const builder = ThumbnailUrlBuilder();

  test('reemplaza el ancho en URLs reales', () {
    const width = PhotosConfig.listThumbnailWidthPixels;
    expect(builder.forUrl(_civic, width), contains('/${width}px-2020_Honda'));
    expect(builder.forUrl(_brz, width), contains('/${width}px-Subaru_BRZ'));
    expect(builder.forUrl(_f150, width), contains('/${width}px-Leimershof'));
  });

  test('conserva el resto de la URL, incluida la consulta', () {
    expect(
      builder.forUrl(_civic, 120),
      _civic.replaceFirst('/960px-', '/120px-'),
    );
  });

  test('solo cambia el segmento de ancho de la miniatura', () {
    expect(builder.forUrl(_brz, 250).split('/960px-'), hasLength(1));
  });

  test('sin segmento de ancho devuelve la misma URL', () {
    const url = 'https://upload.example/thumb/1.jpg';
    expect(builder.forUrl(url, 250), url);
  });
}
