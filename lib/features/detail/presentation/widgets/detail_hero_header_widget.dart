import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_circle_button_widget.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_photo_card_widget.dart';

/// Zona alta de Detalle: mancha de fondo, nombre grande, botones y foto.
class DetailHeroHeaderWidget extends StatelessWidget {
  const DetailHeroHeaderWidget({super.key, required this.args});

  final DetailArgsEntity args;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        height: UiConfig.detailHeroHeight,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              // La mancha se escala al ancho conservando la proporción del lienzo.
              child: AspectRatio(
                aspectRatio:
                    UiConfig.detailBlobCanvasWidth /
                    UiConfig.detailBlobCanvasHeight,
                child: SvgPicture.string(AppShapes.detailBlobSvg()),
              ),
            ),
            Positioned(
              top: UiConfig.detailGhostTop,
              left: 0,
              right: 0,
              child: ExcludeSemantics(child: _GhostTitle(text: args.groupName)),
            ),
            Positioned(
              top: UiConfig.detailPhotoTop,
              left: UiConfig.detailPhotoSideMargin,
              right: UiConfig.detailPhotoSideMargin,
              child: DetailPhotoCardWidget(
                photo: args.photo,
                brandName: args.brand,
                heroTag: args.heroTag,
              ),
            ),
            Positioned(
              top: UiConfig.detailCircleButtonInset,
              left: UiConfig.detailCircleButtonInset,
              child: DetailCircleButtonWidget(
                icon: Symbols.chevron_left,
                size: UiConfig.detailCircleButtonSize,
                iconSize: UiConfig.iconSize,
                semanticLabel: AppTexts.backLabel,
                onTap: () => context.pop(),
              ),
            ),
            const Positioned(
              top: UiConfig.detailCircleButtonInset,
              right: UiConfig.detailCircleButtonInset,
              child: DetailCircleButtonWidget(
                icon: Symbols.favorite,
                size: UiConfig.detailCircleButtonSize,
                iconSize: UiConfig.detailFavoriteIconSize,
                semanticLabel: AppTexts.addToFavoritesLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nombre del modelo en mayúsculas, grande, con degradado y muy tenue.
class _GhostTitle extends StatelessWidget {
  const _GhostTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: UiConfig.detailGhostOpacity,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              style: AppTextStyles.ghostTitle,
            ),
          ),
        ),
      ),
    );
  }
}
