import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_other_year_row_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_section_header_widget.dart';

/// Enlace discreto al final de una lista: "¿No es el que buscas? Buscar en otros años".
class SearchOtherYearsLinkWidget extends StatelessWidget {
  const SearchOtherYearsLinkWidget({
    super.key,
    required this.onTap,
    this.failed = false,
  });

  final VoidCallback onTap;

  /// La búsqueda anterior falló: se avisa y el enlace sirve de reintento.
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          failed
              ? AppTexts.searchOtherYearsFailed
              : AppTexts.searchOtherYearsPrompt,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
        TextButton(
          key: const ValueKey('search-other-years-link'),
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          child: Text(
            AppTexts.searchOtherYearsAction,
            style: AppTextStyles.bodyStrong.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sección "También en otros años": avance cancelable y filas halladas.
class SearchOtherYearsWidget extends StatelessWidget {
  const SearchOtherYearsWidget({
    super.key,
    required this.status,
    required this.onCancel,
    required this.onOpen,
  });

  final SearchOtherYearsStatusEntity status;
  final VoidCallback onCancel;
  final ValueChanged<SearchResultEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final results = status.results;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SearchSectionHeaderWidget(title: AppTexts.searchOtherYearsTitle),
        const SizedBox(height: SearchConfig.sectionTitleGap),
        if (status.isBuilding) ...[
          Semantics(
            label: AppTexts.searchOtherYearsProgressLabel(status.checkedYears),
            excludeSemantics: true,
            child: LinearProgressIndicator(
              key: const ValueKey('search-other-years-progress'),
              value: status.progress,
              minHeight: SearchConfig.progressHeight,
              color: AppColors.accent,
              backgroundColor: AppColors.outline,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppTexts.searchOtherYearsProgressLabel(status.checkedYears),
                  style: AppTextStyles.caption,
                ),
              ),
              TextButton(
                key: const ValueKey('search-other-years-cancel'),
                onPressed: onCancel,
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                child: Text(
                  AppTexts.searchOtherYearsCancel,
                  style: AppTextStyles.bodyStrong,
                ),
              ),
            ],
          ),
        ] else if (results.isEmpty)
          Text(
            status.failedYears.isEmpty
                ? AppTexts.searchOtherYearsNone
                : AppTexts.searchOtherYearsFailed,
            style: AppTextStyles.caption,
          ),
        for (final result in results)
          Padding(
            padding: const EdgeInsets.only(top: SearchConfig.otherYearRowGap),
            child: SearchOtherYearRowWidget(
              key: ValueKey(
                'search-other-year-${result.year}-${result.brand}-${result.groupName}',
              ),
              result: result,
              onTap: () => onOpen(result),
            ),
          ),
      ],
    );
  }
}
