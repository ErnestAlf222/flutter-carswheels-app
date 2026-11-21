import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';

/// Crédito discreto de la foto visible: "Foto: autor · licencia".
///
/// Sin autor no se muestra. Al tocarlo copia el enlace de la fuente, porque la
/// app no tiene un paquete para abrir enlaces externos.
class DetailPhotoCreditWidget extends StatelessWidget {
  const DetailPhotoCreditWidget({super.key, this.onOpenSource});

  /// Reemplaza la acción al tocar (por defecto copia el enlace de la fuente).
  final ValueChanged<String>? onOpenSource;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailGalleryCubit, GalleryState>(
      builder: (context, state) {
        if (state.photos.isEmpty) return const SizedBox.shrink();
        final photo = state.photos[state.currentIndex];
        final author = photo.authorName.trim();
        if (author.isEmpty) return const SizedBox.shrink();
        final label = AppTexts.photoCreditLabel(author, photo.licenseName);
        final hasSource = photo.sourceUrl.trim().isNotEmpty;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            UiConfig.detailInfoSideMargin,
            UiConfig.detailCreditTopMargin,
            UiConfig.detailInfoSideMargin,
            0,
          ),
          child: Semantics(
            button: hasSource,
            label: label,
            hint: hasSource ? AppTexts.photoCreditSemanticHint : null,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hasSource ? () => _open(context, photo.sourceUrl) : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: UiConfig.detailCreditMinTouchHeight,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.attributionNote,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final handler = onOpenSource;
    if (handler != null) {
      handler(url);
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(AppTexts.photoSourceCopiedMessage)),
      );
  }
}
