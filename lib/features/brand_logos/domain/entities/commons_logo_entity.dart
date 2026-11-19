/// Logo de respaldo elegido en Commons, con su licencia y su fuente.
class CommonsLogoEntity {
  const CommonsLogoEntity({
    required this.url,
    required this.licenseName,
    required this.authorName,
    required this.sourceUrl,
  });

  /// URL que carga el widget: el SVG original o una miniatura PNG.
  final String url;
  final String licenseName;
  final String authorName;
  final String sourceUrl;
}
