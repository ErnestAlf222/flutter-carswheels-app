import 'package:flutter/material.dart';

import '../config/core_config.dart';

/// Indicador de carga animado con el GIF de la app.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AssetsConfig.loaderGifPath,
        width: UiConfig.loaderSize,
        height: UiConfig.loaderSize,
        gaplessPlayback: true,
      ),
    );
  }
}
