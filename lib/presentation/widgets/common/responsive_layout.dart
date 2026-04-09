import 'package:flutter/material.dart';

enum ScreenSize { small, medium, large }

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final Widget? mediumChild;
  final Widget? largeChild;

  const ResponsiveLayout({
    Key? key,
    required this.child,
    this.mediumChild,
    this.largeChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = getScreenSize(constraints.maxWidth);
        
        switch (screenSize) {
          case ScreenSize.large:
            return largeChild ?? mediumChild ?? child;
          case ScreenSize.medium:
            return mediumChild ?? child;
          case ScreenSize.small:
            return child;
        }
      },
    );
  }

  static ScreenSize getScreenSize(double width) {
    if (width >= 900) {
      return ScreenSize.large;
    } else if (width >= 600) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.small;
    }
  }

  static bool isTablet(BuildContext context) {
    return getScreenSize(MediaQuery.of(context).size.width) != ScreenSize.small;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenSize(MediaQuery.of(context).size.width) == ScreenSize.large;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);
    
    switch (screenSize) {
      case ScreenSize.large:
        return const EdgeInsets.all(24.0);
      case ScreenSize.medium:
        return const EdgeInsets.all(16.0);
      case ScreenSize.small:
        return const EdgeInsets.all(8.0);
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);
    
    switch (screenSize) {
      case ScreenSize.large:
        return 1200;
      case ScreenSize.medium:
        return 800;
      case ScreenSize.small:
        return double.infinity;
    }
  }
}

class ResponsiveBreakpoints {
  static const double tablet = 600.0;
  static const double desktop = 900.0;
}

extension ResponsiveExtensions on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;
  bool get isTablet => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.tablet &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;
  
  ScreenSize get screenSize => ResponsiveLayout.getScreenSize(MediaQuery.of(this).size.width);
}