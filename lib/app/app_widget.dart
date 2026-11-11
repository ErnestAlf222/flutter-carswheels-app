import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import 'router/app_router.dart';

/// Widget raíz de la app.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = buildAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
