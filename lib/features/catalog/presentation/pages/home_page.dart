import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';

/// Pantalla de inicio (temporal, con relleno).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: AppTexts.homePageTitle);
  }
}
