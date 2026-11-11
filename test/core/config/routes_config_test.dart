import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las rutas son únicas y empiezan con barra', () {
    const routes = [
      RoutesConfig.home,
      RoutesConfig.search,
      RoutesConfig.compare,
      RoutesConfig.favorites,
      RoutesConfig.settings,
    ];
    expect(routes.toSet().length, routes.length);
    expect(routes.every((route) => route.startsWith('/')), isTrue);
  });
}
