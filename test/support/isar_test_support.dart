import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

/// Ayudante para pruebas con Isar real: omite la prueba si no hay núcleo nativo.
class IsarTestSupport {
  const IsarTestSupport._();

  /// Mensaje del omitido; nulo si el núcleo está disponible.
  static String? skipReason;

  /// Intenta preparar el núcleo nativo; guarda la razón si falla.
  static Future<void> prepare() async {
    try {
      await Isar.initializeIsarCore(download: true);
      skipReason = null;
    } catch (error) {
      skipReason =
          'Omitida: no se pudo preparar el núcleo nativo de Isar ($error)';
    }
  }

  /// Devuelve true y marca la prueba como omitida si el núcleo no está.
  static bool skipIfUnavailable() {
    final reason = skipReason;
    if (reason == null) return false;
    markTestSkipped(reason);
    return true;
  }
}
