import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';

/// Pantalla de search (temporal, con relleno).
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: AppTexts.searchPageTitle);
  }
}
