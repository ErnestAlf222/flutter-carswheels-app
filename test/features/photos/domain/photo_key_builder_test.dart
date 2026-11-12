import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = PhotoKeyBuilder(selector: PhotoCandidateSelector());

  String key(String model, {String brand = 'Honda', int year = 2020}) =>
      builder.build(brand: brand, modelName: model, year: year);

  test('construye marca|modelo|año normalizados', () {
    expect(key('Civic 4Dr'), 'honda|civic|2020');
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
