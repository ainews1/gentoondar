import 'package:flutter/material.dart';
import '../widgets/charts/productivity_charts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProductivityChartsWidget(),
    );
  }
}