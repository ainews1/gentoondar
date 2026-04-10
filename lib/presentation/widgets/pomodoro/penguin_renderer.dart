import 'dart:math';

import 'package:flutter/material.dart';
import 'package:task_calendar_app/domain/entities/penguin_state.dart';

/// Procedural pixel art CustomPainter for the Gentoo penguin mascot (D-43, D-44, D-45).
///
/// Renders a 16x16 logical pixel grid into an 80x80px display area.
/// Penguin appearance is procedurally generated from [state.seed], producing
/// unique color palettes, accessories (based on evolution stage), and
/// proportions for each user.
///
/// Animation frames cycle through idle animations: waddle, blink, look-around.
class PenguinRenderer extends CustomPainter {
  PenguinRenderer({
    required this.state,
    required this.animationFrame,
    this.auraColor,
  });

  /// Current penguin state (seed, evolution stage, etc.)
  final PenguinState state;

  /// Current animation frame (0-7) for idle animations
  final int animationFrame;

  /// Optional aura/glow color from the active theme
  final Color? auraColor;

  // Cached Paint objects for performance (Research pitfall 4)
  static final Paint _bodyPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _bellyPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _beakPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _eyeWhitePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;
  static final Paint _eyePupilPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black;
  static final Paint _auraPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _accessoryPaint = Paint()..style = PaintingStyle.fill;

  // Body color options (8)
  static const List<Color> _bodyColors = [
    Color(0xFF1A1A2E), // dark navy
    Color(0xFF16213E), // dark blue
    Color(0xFF0F3460), // medium blue
    Color(0xFF1B1B3A), // dark purple
    Color(0xFF1A3C40), // dark teal
    Color(0xFF2D2D2D), // dark grey
    Color(0xFF1E3A2F), // dark green
    Color(0xFF2C1654), // dark violet
  ];

  // Belly color options (4)
  static const List<Color> _bellyColors = [
    Color(0xFFF5F5F5), // white
    Color(0xFFFFF8DC), // cream
    Color(0xFFE0F0FF), // light blue
    Color(0xFFFFFDE7), // light yellow
  ];

  // Beak color options (3)
  static const List<Color> _beakColors = [
    Color(0xFFFF8C00), // orange
    Color(0xFFFFD700), // yellow
    Color(0xFFE53935), // red
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 16;
    final random = Random(state.seed);

    // Determine procedural colors
    final bodyColor = _bodyColors[random.nextInt(_bodyColors.length)];
    final bellyColor = _bellyColors[random.nextInt(_bellyColors.length)];
    final beakColor = _beakColors[random.nextInt(_beakColors.length)];
    final feetColor = beakColor; // feet match beak

    _bodyPaint.color = bodyColor;
    _bellyPaint.color = bellyColor;
    _beakPaint.color = beakColor;

    // Body-head ratio variation (D-45)
    final bodyHeadRatio = 0.6 + random.nextDouble() * 0.2;
    // Adjust head row range based on ratio (higher ratio = larger head)
    final headTopRow = bodyHeadRatio > 0.7 ? 1 : 2;

    // Calculate animation offset for waddle
    int xOffset = 0;
    if (animationFrame == 1) {
      xOffset = -1; // lean left
    } else if (animationFrame == 3) {
      xOffset = 1; // lean right
    }

    // Draw aura if color provided
    if (auraColor != null) {
      final auraOpacity = 0.1 + (state.evolutionStage * 0.02).clamp(0.0, 0.2);
      _auraPaint.color = auraColor!.withValues(alpha: auraOpacity);
      // Aura: 2px wider than body on each side
      for (int row = headTopRow; row <= 14; row++) {
        for (int col = 2; col <= 13; col++) {
          _drawPixel(canvas, col + xOffset, row, pixelSize, _auraPaint);
        }
      }
    }

    // Draw body (rows 4-13, cols 4-11)
    for (int row = 4; row <= 13; row++) {
      for (int col = 4; col <= 11; col++) {
        _drawPixel(canvas, col + xOffset, row, pixelSize, _bodyPaint);
      }
    }

    // Draw head (rows headTopRow-5, cols 5-10)
    for (int row = headTopRow; row <= 5; row++) {
      for (int col = 5; col <= 10; col++) {
        _drawPixel(canvas, col + xOffset, row, pixelSize, _bodyPaint);
      }
    }

    // Draw belly (rows 6-12, cols 6-9)
    for (int row = 6; row <= 12; row++) {
      for (int col = 6; col <= 9; col++) {
        _drawPixel(canvas, col + xOffset, row, pixelSize, _bellyPaint);
      }
    }

    // Draw eyes (row 3, cols 6 and 9)
    final bool isBlinking = animationFrame == 4 || animationFrame == 5;
    const int eyeRow = 3;

    if (isBlinking) {
      // Blink: narrow eyes (single line)
      _drawPixel(canvas, 6 + xOffset, eyeRow, pixelSize, _eyeWhitePaint);
      _drawPixel(canvas, 9 + xOffset, eyeRow, pixelSize, _eyeWhitePaint);
    } else {
      // Normal eyes: white with pupil
      _drawPixel(canvas, 6 + xOffset, eyeRow, pixelSize, _eyeWhitePaint);
      _drawPixel(canvas, 9 + xOffset, eyeRow, pixelSize, _eyeWhitePaint);

      // Pupils - shift for look-around animation
      int pupilLeftCol = 6;
      int pupilRightCol = 9;
      if (animationFrame == 6) {
        pupilLeftCol = 5; // look left
        pupilRightCol = 8;
      } else if (animationFrame == 7) {
        pupilLeftCol = 7; // look right
        pupilRightCol = 10;
      }
      // Draw smaller pupil dots (half pixel at center)
      final pupilRect = Rect.fromLTWH(
        (pupilLeftCol + xOffset) * pixelSize + pixelSize * 0.25,
        eyeRow * pixelSize + pixelSize * 0.25,
        pixelSize * 0.5,
        pixelSize * 0.5,
      );
      canvas.drawRect(pupilRect, _eyePupilPaint);

      final pupilRect2 = Rect.fromLTWH(
        (pupilRightCol + xOffset) * pixelSize + pixelSize * 0.25,
        eyeRow * pixelSize + pixelSize * 0.25,
        pixelSize * 0.5,
        pixelSize * 0.5,
      );
      canvas.drawRect(pupilRect2, _eyePupilPaint);
    }

    // Draw beak (row 4, cols 7-8)
    _drawPixel(canvas, 7 + xOffset, 4, pixelSize, _beakPaint);
    _drawPixel(canvas, 8 + xOffset, 4, pixelSize, _beakPaint);

    // Draw feet (row 14, cols 5-6 and 9-10)
    _beakPaint.color = feetColor;
    _drawPixel(canvas, 5 + xOffset, 14, pixelSize, _beakPaint);
    _drawPixel(canvas, 6 + xOffset, 14, pixelSize, _beakPaint);
    _drawPixel(canvas, 9 + xOffset, 14, pixelSize, _beakPaint);
    _drawPixel(canvas, 10 + xOffset, 14, pixelSize, _beakPaint);

    // Draw accessories based on evolution stage
    _drawAccessories(canvas, pixelSize, random, xOffset, headTopRow);
  }

  void _drawAccessories(
    Canvas canvas,
    double pixelSize,
    Random random,
    int xOffset,
    int headTopRow,
  ) {
    final stage = state.evolutionStage;

    if (stage >= 1) {
      // Hat options at stage 1+
      final hatOptions = <void Function()>[
        // Top hat (2 pixels tall at row 0-1, cols 6-9)
        () {
          _accessoryPaint.color = const Color(0xFF333333);
          for (int col = 6; col <= 9; col++) {
            _drawPixel(
                canvas, col + xOffset, headTopRow - 1, pixelSize, _accessoryPaint);
          }
          for (int col = 7; col <= 8; col++) {
            _drawPixel(
                canvas, col + xOffset, headTopRow - 2, pixelSize, _accessoryPaint);
          }
        },
        // Beanie (row 0, cols 5-10, colored)
        () {
          _accessoryPaint.color = const Color(0xFFE53935);
          for (int col = 5; col <= 10; col++) {
            _drawPixel(
                canvas, col + xOffset, headTopRow - 1, pixelSize, _accessoryPaint);
          }
        },
        // Crown (row 0, cols 6-9, gold)
        () {
          _accessoryPaint.color = const Color(0xFFFFD700);
          for (int col = 6; col <= 9; col++) {
            _drawPixel(
                canvas, col + xOffset, headTopRow - 1, pixelSize, _accessoryPaint);
          }
          // Crown points
          _drawPixel(
              canvas, 6 + xOffset, headTopRow - 2, pixelSize, _accessoryPaint);
          _drawPixel(
              canvas, 9 + xOffset, headTopRow - 2, pixelSize, _accessoryPaint);
        },
      ];

      final hatIndex = random.nextInt(hatOptions.length);
      hatOptions[hatIndex]();
    }

    if (stage >= 3) {
      // Scarf (rows 5-6, colored band)
      final scarfColors = [
        const Color(0xFFE53935),
        const Color(0xFF1E88E5),
        const Color(0xFF43A047),
        const Color(0xFFFFB300),
      ];
      _accessoryPaint.color = scarfColors[random.nextInt(scarfColors.length)];
      for (int col = 4; col <= 11; col++) {
        _drawPixel(canvas, col + xOffset, 5, pixelSize, _accessoryPaint);
      }
    }

    if (stage >= 5) {
      // Glasses (row 3, over eyes)
      _accessoryPaint.color = const Color(0xFF616161);
      // Left lens frame
      _drawPixel(canvas, 5 + xOffset, 3, pixelSize, _accessoryPaint);
      _drawPixel(canvas, 7 + xOffset, 3, pixelSize, _accessoryPaint);
      // Right lens frame
      _drawPixel(canvas, 8 + xOffset, 3, pixelSize, _accessoryPaint);
      _drawPixel(canvas, 10 + xOffset, 3, pixelSize, _accessoryPaint);
    }
  }

  /// Draw a single pixel at grid coordinates
  void _drawPixel(
    Canvas canvas,
    int col,
    int row,
    double pixelSize,
    Paint paint,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(
        col * pixelSize,
        row * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PenguinRenderer oldDelegate) {
    return state != oldDelegate.state ||
        animationFrame != oldDelegate.animationFrame ||
        auraColor != oldDelegate.auraColor;
  }
}
