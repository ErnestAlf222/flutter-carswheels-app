import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Abre una hoja inferior con las esquinas, el asa y el alto de las de Comparar.
///
/// Va en el navegador raíz para quedar sobre la barra flotante de pestañas.
Future<T?> showCompareSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color backgroundColor = AppColors.surface,
  double maxHeightFraction = UiConfig.detailSheetMaxHeightFraction,
}) {
  final media = MediaQuery.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
    ),
    constraints: BoxConstraints(
      maxHeight: media.size.height * maxHeightFraction,
    ),
    sheetAnimationStyle: media.disableAnimations
        ? AnimationStyle.noAnimation
        : null,
    builder: builder,
  );
}

/// Asa, título y contenido de una hoja; la versión oscura usa tinta y texto claro.
class CompareSheetFrameWidget extends StatelessWidget {
  const CompareSheetFrameWidget({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s),
        Center(
          child: Container(
            width: UiConfig.detailSheetHandleWidth,
            height: UiConfig.detailSheetHandleHeight,
            decoration: BoxDecoration(
              color: dark ? AppColors.chartAxis : AppColors.outline,
              borderRadius: BorderRadius.circular(
                UiConfig.detailSheetHandleHeight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: dark
                    ? AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.onDark,
                      )
                    : AppTextStyles.sectionTitle,
              ),
              if (subtitleText != null)
                Text(
                  subtitleText,
                  style: dark
                      ? AppTextStyles.onDarkCaption
                      : AppTextStyles.caption,
                ),
            ],
          ),
        ),
        Flexible(child: child),
      ],
    );
  }
}
