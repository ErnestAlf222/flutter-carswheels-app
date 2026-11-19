/// Archivo de Commons que podría ser el logo de una marca.
class CommonsLogoCandidateEntity {
  const CommonsLogoCandidateEntity({
    required this.title,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.mime,
    required this.licenseName,
    required this.authorName,
    required this.sourceUrl,
    required this.rank,
    this.categories = const [],
  });

  /// Título de la página, con prefijo "File:" y extensión.
  final String title;
  final String fileUrl;
  final String thumbnailUrl;
  final String mime;
  final String licenseName;
  final String authorName;
  final String sourceUrl;
  final int rank;

  /// Categorías de Commons del archivo, sin el prefijo "Category:".
  final List<String> categories;
}
