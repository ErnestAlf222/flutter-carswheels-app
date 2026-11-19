import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Encabezado de sección: overline, subtítulo opcional y nota opcional.
class SearchSectionHeaderWidget extends StatelessWidget {
  const SearchSectionHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.note,
  });

  final String title;

  /// Línea destacada bajo el overline (la marca, por ejemplo).
  final String? subtitle;

  /// Aviso discreto, como "Mostrando los primeros N".
  final String? note;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    final extra = note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.label),
        if (sub != null)
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
        if (extra != null) Text(extra, style: AppTextStyles.caption),
      ],
    );
  }
}
