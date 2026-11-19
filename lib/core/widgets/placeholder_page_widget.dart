import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Pantalla temporal de relleno; la reemplaza cada pantalla real.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            UiConfig.navClearance,
          ),
          itemCount: UiConfig.placeholderItemCount + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(title, style: AppTextStyles.screenTitle);
            }
            return Container(
              height: UiConfig.placeholderItemHeight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: const Border.fromBorderSide(
                  BorderSide(
                    color: AppColors.outline,
                    width: UiConfig.cardBorderWidth,
                  ),
                ),
                boxShadow: AppShadows.soft,
              ),
              child: Text(
                AppTexts.placeholderItemLabel,
                style: AppTextStyles.bodyStrong,
              ),
            );
          },
        ),
      ),
    );
  }
}
