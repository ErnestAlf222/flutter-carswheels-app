import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorites_empty_painter.dart';

/// Estado vacío: ilustración, título, ayuda y el botón principal "Explorar autos".
class FavoritesEmptyWidget extends StatelessWidget {
  const FavoritesEmptyWidget({super.key, required this.onExplore});

  /// Lleva a Inicio; lo define la capa app.
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.pageHorizontalPadding,
        FavoritesConfig.emptyTopGap,
        UiConfig.pageHorizontalPadding,
        0,
      ),
      child: Column(
        children: [
          // La ilustración es decorativa: el título ya dice lo mismo.
          const ExcludeSemantics(
            child: SizedBox(
              width: FavoritesConfig.emptyIllustrationSize,
              height: FavoritesConfig.emptyIllustrationSize,
              child: CustomPaint(painter: FavoritesEmptyPainter()),
            ),
          ),
          const SizedBox(height: FavoritesConfig.emptyTitleGap),
          Text(
            AppTexts.favoritesEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: FavoritesConfig.emptyBodyGap),
          Text(
            AppTexts.favoritesEmptyBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.infoLabel,
          ),
          const SizedBox(height: FavoritesConfig.emptyButtonGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: FavoritesConfig.emptyButtonMaxWidth,
            ),
            child: AccentButton(
              label: AppTexts.favoritesExploreLabel,
              onPressed: onExplore,
            ),
          ),
        ],
      ),
    );
  }
}
