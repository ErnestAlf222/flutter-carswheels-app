import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Pantalla de favorites (temporal, con relleno).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: AppTexts.favoritesPageTitle);
  }
}
