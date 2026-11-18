import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';

/// Estrategia de orden de los recalls: burbuja si son pocos, Shell si son muchos.
const SortStrategy<RecallEntity> _defaultSortStrategy =
    AdaptiveSortStrategy<RecallEntity>(
      smallListStrategy: BubbleSortStrategy<RecallEntity>(),
      largeListStrategy: ShellSortStrategy<RecallEntity>(),
    );

/// Abre la hoja inferior con la lista de recalls.
Future<void> showRecallsSheet(
  BuildContext context, {
  required RecallSummaryEntity summary,
  SortStrategy<RecallEntity> sortStrategy = _defaultSortStrategy,
}) {
  final media = MediaQuery.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
    ),
    constraints: BoxConstraints(
      maxHeight: media.size.height * UiConfig.detailSheetMaxHeightFraction,
    ),
    sheetAnimationStyle: media.disableAnimations
        ? AnimationStyle.noAnimation
        : null,
    builder: (_) =>
        RecallsSheetWidget(summary: summary, sortStrategy: sortStrategy),
  );
}

/// Contenido de la hoja: asa, título, nota de origen y recalls de más reciente a más antiguo.
class RecallsSheetWidget extends StatelessWidget {
  const RecallsSheetWidget({
    super.key,
    required this.summary,
    this.sortStrategy = _defaultSortStrategy,
  });

  final RecallSummaryEntity summary;
  final SortStrategy<RecallEntity> sortStrategy;

  /// Más reciente primero; sin fecha al final y, a igual fecha, por campaña.
  static int compareNewestFirst(RecallEntity a, RecallEntity b) {
    final dateA = a.reportDate;
    final dateB = b.reportDate;
    if (dateA == null && dateB == null) {
      return b.campaignNumber.compareTo(a.campaignNumber);
    }
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    final byDate = dateB.compareTo(dateA);
    return byDate != 0 ? byDate : b.campaignNumber.compareTo(a.campaignNumber);
  }

  @override
  Widget build(BuildContext context) {
    final recalls = sortStrategy.sort(summary.recalls, compareNewestFirst);
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
              color: AppColors.line,
              borderRadius: BorderRadius.circular(
                UiConfig.detailSheetHandleHeight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xs,
          ),
          child: Text(
            AppTexts.recallsSheetTitle,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Text(AppTexts.recallsSourceNote, style: AppTextStyles.caption),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recalls.length,
            itemBuilder: (context, index) =>
                _RecallItem(recall: recalls[index]),
          ),
        ),
      ],
    );
  }
}

/// Un recall: componente, fecha y bloques expandibles de resumen, consecuencia y remedio.
class _RecallItem extends StatelessWidget {
  const _RecallItem({required this.recall});

  final RecallEntity recall;

  @override
  Widget build(BuildContext context) {
    final date = recall.reportDate;
    final campaign = AppTexts.recallCampaignLabel(recall.campaignNumber);
    final blocks = [
      (AppTexts.recallSummaryTitle, recall.summary),
      (AppTexts.recallConsequenceTitle, recall.consequence),
      (AppTexts.recallRemedyTitle, recall.remedy),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: UiConfig.recallItemVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recall.component ?? campaign, style: AppTextStyles.bodyStrong),
          Text(
            [
              if (date != null) DateTexts.longDate(date),
              campaign,
            ].join(AppTexts.creditSeparator),
            style: AppTextStyles.caption,
          ),
          for (final (title, text) in blocks)
            if (text != null && text.isNotEmpty)
              _ExpandableBlock(title: title, text: text),
          const DashedDividerWidget(),
        ],
      ),
    );
  }
}

/// Bloque que se abre y se cierra con el texto original de NHTSA.
class _ExpandableBlock extends StatelessWidget {
  const _ExpandableBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
        expandedAlignment: Alignment.centerLeft,
        title: Text(title, style: AppTextStyles.infoValue),
        children: [Text(text, style: AppTextStyles.recallBody)],
      ),
    );
  }
}
