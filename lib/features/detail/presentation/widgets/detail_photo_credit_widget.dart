import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';

/// Crédito discreto de la foto visible: "Foto: autor · licencia".
///
/// Sin autor no se muestra. Al tocarlo abre la fuente en el navegador externo;
/// si no se puede, copia el enlace y lo avisa.
class DetailPhotoCreditWidget extends StatelessWidget {
  const DetailPhotoCreditWidget({super.key, this.launcher = _launchExternal});

  /// Abre el enlace fuera de la app; devuelve false si no pudo (inyectable).
  final Future<bool> Function(Uri url) launcher;

  static Future<bool> _launchExternal(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

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
    if (await _tryLaunch(url)) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(AppTexts.photoSourceCopiedMessage)),
      );
  }

  Future<bool> _tryLaunch(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    try {
      return await launcher(uri);
    } on Object {
      return false;
    }
  }
}
