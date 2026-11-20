import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Fila de la barra compacta de Marcas: logo, nombre y selector sin desbordar.
class BrandCompactBarWidget extends StatelessWidget {
  const BrandCompactBarWidget({
    super.key,
    required this.brandName,
    required this.logo,
    required this.selector,
  });

  final String brandName;

  /// Logo de la marca; si es muy ancho se reduce para caber (BoxFit.contain).
  final Widget logo;

  /// Selector de mercado y año: conserva siempre su tamaño.
  final Widget selector;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: UiConfig.headerCompactLogoMaxWidth,
                    maxHeight: UiConfig.headerCompactLogoMaxHeight,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: logo,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                flex: 2,
                child: Text(
                  brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        selector,
      ],
    );
  }
}
