import 'package:flutter/material.dart';

import '../core/core.dart';

/// Widget raíz de la app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Pantalla temporal: la reemplaza la navegación de la parte B.
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppConfig.appName, style: AppTextStyles.screenTitle),
              const AppLoader(),
            ],
          ),
        ),
      ),
    );
  }
}
