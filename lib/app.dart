import 'package:flutter/material.dart';

import 'package:uas_duolingo/core/router/app_router.dart';
import 'package:uas_duolingo/core/theme/app_theme.dart';

class MultilingoApp extends StatelessWidget {
  const MultilingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Multilingo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}