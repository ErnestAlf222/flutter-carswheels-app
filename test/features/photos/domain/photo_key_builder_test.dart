import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = PhotoKeyBuilder(selector: PhotoCandidateSelector());

  String key(String model, {String brand = 'Honda', int year = 2020}) =>
      builder.build(brand: brand, modelName: model, year: year);

  test('construye versión|marca|modelo|año normalizados', () {
    const separator = PhotosConfig.cacheKeySeparator;
    expect(
      key('Civic 4Dr'),
      [
        PhotosConfig.photoCacheKeyVersion,
        'honda',
        'civic',
        '2020',
      ].join(separator),
    );
  });

  test('la clave empieza con la versión de la caché', () {
    expect(
      key('Civic').startsWith(
        '${PhotosConfig.photoCacheKeyVersion}${PhotosConfig.cacheKeySeparator}',
      ),
      isTrue,
    );
  });

  test('Civic 2Dr y Civic 4Dr dan la misma clave', () {
    expect(key('Civic 2Dr'), key('Civic 4Dr'));
  });

  test('otro año da otra clave', () {
    expect(key('Civic 4Dr', year: 2021), isNot(key('Civic 4Dr')));
  });

  test('otra marca da otra clave', () {
    expect(key('Civic', brand: 'Toyota'), isNot(key('Civic')));
  });
}
