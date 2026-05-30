import 'package:flutter/material.dart';
import 'package:price_tracker_app/app/router.dart';
import 'package:price_tracker_app/core/theme.dart';

class PriceTrackerApp extends StatelessWidget {
  const PriceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Price Tracker',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
