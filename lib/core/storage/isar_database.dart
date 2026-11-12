import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cars_wheels_app/core/config/config.dart';

/// Abre y cierra la base de datos Isar de la app.
class IsarDatabase {
  const IsarDatabase._();

  /// Abre la base en el directorio de documentos con los esquemas dados.
  static Future<Isar> open(List<CollectionSchema<dynamic>> schemas) async {
    final directory = await getApplicationDocumentsDirectory();
    return Isar.open(
      schemas,
      directory: directory.path,
      name: StorageConfig.isarDatabaseName,
    );
  }

  /// Cierra la instancia sin borrar los datos.
  static Future<void> close(Isar isar) => isar.close();
}
