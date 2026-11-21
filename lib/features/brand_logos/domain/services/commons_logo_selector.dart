import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/entities/commons_logo_candidate_entity.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/entities/commons_logo_entity.dart';

/// Elige el logo de una marca entre los archivos de Commons, o ninguno.
class CommonsLogoSelector {
  const CommonsLogoSelector();

  static final RegExp _extensionPattern = RegExp(r'\.[A-Za-z0-9]{2,4}$');
  static final RegExp _tokenPattern = RegExp(r'[^a-z0-9]+');

  /// Acepta solo títulos que sean la marca más "logo" y palabras de relleno,
  /// con SVG/PNG, licencia permitida y categoría vehicular; prefiere SVG y luego el mejor rank.
  CommonsLogoEntity? select(
    String brandName,
    List<CommonsLogoCandidateEntity> candidates,
  ) {
    final brandTokens = _tokens(brandName);
    if (brandTokens.isEmpty) return null;
    final accepted = [
      for (final candidate in candidates)
        if (_isAcceptable(candidate, brandTokens)) candidate,
    ]..sort(_compare);
    if (accepted.isEmpty) return null;
    final best = accepted.first;
    return CommonsLogoEntity(
      url: _withoutQuery(
        best.mime == LogosConfig.commonsSvgMime
            ? best.fileUrl
            : best.thumbnailUrl,
      ),
      licenseName: best.licenseName,
      authorName: best.authorName,
      sourceUrl: best.sourceUrl,
    );
  }

  // Commons agrega parámetros de seguimiento; sin ellos la URL termina en .svg.
  String _withoutQuery(String url) => url.split('?').first;

  bool _isAcceptable(
    CommonsLogoCandidateEntity candidate,
    List<String> brandTokens,
  ) {
    if (candidate.mime != LogosConfig.commonsSvgMime &&
        candidate.mime != LogosConfig.commonsPngMime) {
      return false;
    }
    if (!_isLicenseAllowed(candidate.licenseName)) return false;
    if (!_isVehicleRelated(candidate.categories)) return false;
    final title = candidate.title
        .replaceFirst(PhotosConfig.filePrefix, '')
        .replaceFirst(_extensionPattern, '');
    final tokens = _tokens(title);
    // Debe llevar todas las palabras de la marca y la palabra "logo".
    if (!brandTokens.every(tokens.contains)) return false;
    if (!tokens.contains(LogosConfig.commonsLogoSearchSuffix)) return false;
    // Cualquier otra palabra distinta de relleno indica otra marca u otro uso.
    return tokens.every(
      (token) =>
          brandTokens.contains(token) ||
          LogosConfig.commonsLogoNoiseWords.contains(token),
    );
  }

  // Al menos una categoría de tema vehicular; sin categorías no se acepta.
  bool _isVehicleRelated(List<String> categories) => categories.any(
    (category) => LogosConfig.commonsVehicleCategoryKeywords.any(
      category.toLowerCase().contains,
    ),
  );

  bool _isLicenseAllowed(String licenseName) => LogosConfig
      .commonsAllowedLicensePrefixes
      .any((prefix) => licenseName.startsWith(prefix));

  int _compare(CommonsLogoCandidateEntity a, CommonsLogoCandidateEntity b) {
    final aSvg = a.mime == LogosConfig.commonsSvgMime ? 0 : 1;
    final bSvg = b.mime == LogosConfig.commonsSvgMime ? 0 : 1;
    if (aSvg != bSvg) return aSvg.compareTo(bSvg);
    final byRank = a.rank.compareTo(b.rank);
    return byRank != 0 ? byRank : a.title.compareTo(b.title);
  }

  // Palabras en minúsculas; todo lo que no sea letra o número separa.
  List<String> _tokens(String text) => text
      .toLowerCase()
      .split(_tokenPattern)
      .where((token) => token.isNotEmpty)
      .toList();
}
