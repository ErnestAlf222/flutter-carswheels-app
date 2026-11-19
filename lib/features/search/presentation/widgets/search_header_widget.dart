import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/domain.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_context_chip_widget.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_field_widget.dart';

/// Encabezado compacto: título, contexto y el campo a caballo sobre el borde.
class SearchHeaderWidget extends StatelessWidget {
  const SearchHeaderWidget({
    super.key,
    required this.scope,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final SearchScopeEntity? scope;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final current = scope;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SearchConfig.fieldOverlap),
          child: HeroHeaderWidget(
            padding: EdgeInsets.only(
              top: topInset + HeaderConfig.contentTopPadding,
              bottom:
                  HeaderConfig.contentBottomPadding + SearchConfig.fieldOverlap,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConfig.pageHorizontalPadding,
              ),
              child: SizedBox(
                height: SearchConfig.headerTitleRowHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppTexts.searchPageTitle,
                        style: AppTextStyles.onDarkScreenTitle,
                      ),
                    ),
                    if (current != null)
                      SearchContextChipWidget(
                        marketCode: current.marketCode,
                        year: current.year,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            child: SearchFieldWidget(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onClear: onClear,
            ),
          ),
        ),
      ],
    );
  }
}
