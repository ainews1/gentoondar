import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { calendar, tasks, week }

// Current tab selection
final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.calendar);

// Navigation index for bottom nav bar
final navigationIndexProvider = Provider<int>((ref) {
  final currentTab = ref.watch(currentTabProvider);
  return currentTab.index;
});