import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_sheet_frame_widget.dart';

/// Abre la hoja inferior con las versiones disponibles de un vehículo.
///
/// [onSelected] recibe la clave elegida; nula es la versión predeterminada.
Future<void> showCompareVersionSheet(
  BuildContext context, {
  required CompareSlotEntity slot,
  required CompareVersionsSource source,
  required ValueChanged<String?> onSelected,
}) => showCompareSheet<void>(
  context,
  builder: (_) => CompareVersionSheetWidget(
    slot: slot,
    source: source,
    onSelected: onSelected,
  ),
);

/// Contenido de la hoja: asa, título y la lista de versiones del modelo.
class CompareVersionSheetWidget extends StatefulWidget {
  const CompareVersionSheetWidget({
    super.key,
    required this.slot,
    required this.source,
    required this.onSelected,
  });

  final CompareSlotEntity slot;
  final CompareVersionsSource source;
  final ValueChanged<String?> onSelected;

  @override
  State<CompareVersionSheetWidget> createState() =>
      _CompareVersionSheetWidgetState();
}

class _CompareVersionSheetWidgetState extends State<CompareVersionSheetWidget> {
  // Carga de las versiones; se vuelve a pedir al reintentar.
  late Future<List<CompareVersionOptionEntity>> _versions;

  @override
  void initState() {
    super.initState();
    _versions = widget.source.versionsOf(widget.slot);
  }

  void _retry() {
    final versions = widget.source.versionsOf(widget.slot);
    setState(() {
      _versions = versions;
    });
  }

  void _select(String? key) {
    widget.onSelected(key);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CompareSheetFrameWidget(
      title: AppTexts.compareVersionSheetTitle(
        widget.slot.brand,
        widget.slot.modelName,
      ),
      subtitle: AppTexts.compareVersionSheetSubtitle,
      child: FutureBuilder<List<CompareVersionOptionEntity>>(
        future: _versions,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _Failed(onRetry: _retry);
          final options = snapshot.data;
          if (options == null) {
            return const Padding(
              padding: EdgeInsets.all(CompareConfig.sheetStatusPadding),
              child: AppLoader(compact: true),
            );
          }
          return _Options(
            options: options,
            selectedKey: widget.slot.versionKey,
            onSelected: _select,
          );
        },
      ),
    );
  }
}

/// Lista con la versión predeterminada primero y luego cada opción.
class _Options extends StatelessWidget {
  const _Options({
    required this.options,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<CompareVersionOptionEntity> options;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(CompareConfig.sheetStatusPadding),
        child: Text(
          AppTexts.compareVersionSheetEmpty,
          textAlign: TextAlign.center,
          style: AppTextStyles.infoLabel,
        ),
      );
    }
    return ListView(
      shrinkWrap: true,
      children: [
        _Row(
          title: AppTexts.compareVersionDefaultLabel,
          caption: AppTexts.compareVersionDefaultCaption,
          isSelected: selectedKey == null,
          onTap: () => onSelected(null),
        ),
        for (final option in options)
          _Row(
            title: option.label,
            caption: option.caption,
            isDefault: option.isDefault,
            isSelected: option.key == selectedKey,
            onTap: () => onSelected(option.key),
          ),
      ],
    );
  }
}

/// Una versión de la lista, con una marca si es la elegida.
class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.caption,
    this.isDefault = false,
  });

  final String title;
  final String? caption;
  final bool isSelected;

  /// Marca la versión que Detalle elige por defecto.
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = caption;
    return Semantics(
      button: true,
      selected: isSelected,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CompareConfig.versionRowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.bodyStrong),
                      if (isDefault)
                        Text(
                          AppTexts.compareVersionDefaultLabel,
                          style: AppTextStyles.caption,
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: CompareConfig.versionCheckSize,
                    height: CompareConfig.versionCheckSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                    child: const Icon(
                      Symbols.check,
                      size: CompareConfig.versionCheckIconSize,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error al pedir las versiones, con la acción de reintentar.
class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CompareConfig.sheetStatusPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTexts.compareColumnLoadFailed,
            textAlign: TextAlign.center,
            style: AppTextStyles.infoLabel,
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ink,
              minimumSize: const Size(0, CompareConfig.removeTouchSize),
            ),
            child: Text(
              AppTexts.retryButtonLabel,
              style: AppTextStyles.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
