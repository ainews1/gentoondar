import 'package:flutter/material.dart';

class LarryLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isIcon;
  
  const LarryLogo({
    Key? key,
    this.size = 80.0,
    this.color,
    this.isIcon = false,
  }) : super(key: key);
  
  // Factory constructor for app bar icon
  const LarryLogo.icon({
    Key? key,
    this.size = 24.0,
    this.color,
  }) : isIcon = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now, we'll create the Larry logo using a Container with custom painting
    // In a real app, you'd use an SVG asset: SvgPicture.asset('assets/larry_logo.svg')
    
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LarryLogoPainter(color: color ?? const Color(0xFF54487A)),
      ),
    );
  }
}

class LarryLogoPainter extends CustomPainter {
  final Color color;
  
  LarryLogoPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final spotPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
      
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    
    // Larry's body
    final bodyRect = RRect.fromLTRBXY(
      centerX - 25, centerY + 5, centerX + 25, centerY + 30,
      15, 15
    );
    canvas.drawRRect(bodyRect, paint);
    
    // Larry's head
    final headRect = RRect.fromLTRBXY(
      centerX - 20, centerY - 25, centerX + 20, centerY + 5,
      20, 20
    );
    canvas.drawRRect(headRect, paint);
    
    // Larry's spots
    canvas.drawCircle(Offset(centerX - 8, centerY + 15), 4, spotPaint);
    canvas.drawCircle(Offset(centerX + 10, centerY + 20), 3, spotPaint);
    canvas.drawCircle(Offset(centerX - 5, centerY + 25), 2.5, spotPaint);
    canvas.drawCircle(Offset(centerX - 5, centerY - 15), 2, spotPaint);
    canvas.drawCircle(Offset(centerX + 8, centerY - 10), 2, spotPaint);
    
    // Larry's horns
    final hornPath1 = Path();
    hornPath1.moveTo(centerX - 10, centerY - 20);
    hornPath1.lineTo(centerX - 8, centerY - 30);
    hornPath1.lineTo(centerX - 5, centerY - 20);
    hornPath1.close();
    canvas.drawPath(hornPath1, paint);
    
    final hornPath2 = Path();
    hornPath2.moveTo(centerX + 5, centerY - 20);
    hornPath2.lineTo(centerX + 8, centerY - 30);
    hornPath2.lineTo(centerX + 10, centerY - 20);
    hornPath2.close();
    canvas.drawPath(hornPath2, paint);
    
    // Larry's ears
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 15, centerY - 15), width: 8, height: 12),
      paint
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 15, centerY - 15), width: 8, height: 12),
      paint
    );
    
    // Larry's eyes
    final eyePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final pupilPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 7, centerY - 10), 3, eyePaint);
    canvas.drawCircle(Offset(centerX + 7, centerY - 10), 3, eyePaint);
    canvas.drawCircle(Offset(centerX - 7, centerY - 10), 2, pupilPaint);
    canvas.drawCircle(Offset(centerX + 7, centerY - 10), 2, pupilPaint);
    
    // Larry's snout
    final snoutPaint = Paint()
      ..color = Color(0xFFB8A9DB)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY - 2), width: 12, height: 8),
      snoutPaint
    );
    
    // Nostrils
    canvas.drawCircle(Offset(centerX - 2, centerY - 5), 1, outlinePaint);
    canvas.drawCircle(Offset(centerX + 2, centerY - 5), 1, outlinePaint);
    
    // Larry's mouth - simple smile
    final mouthPath = Path();
    mouthPath.moveTo(centerX - 8, centerY + 2);
    mouthPath.quadraticBezierTo(centerX, centerY + 6, centerX + 8, centerY + 2);
    canvas.drawPath(mouthPath, outlinePaint);
    
    // Larry's legs
    final legPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
      
    canvas.drawRRect(
      RRect.fromLTRBXY(centerX - 20, centerY + 30, centerX - 15, centerY + 38, 2, 2),
      legPaint
    );
    canvas.drawRRect(
      RRect.fromLTRBXY(centerX - 10, centerY + 30, centerX - 5, centerY + 38, 2, 2),
      legPaint
    );
    canvas.drawRRect(
      RRect.fromLTRBXY(centerX + 5, centerY + 30, centerX + 10, centerY + 38, 2, 2),
      legPaint
    );
    canvas.drawRRect(
      RRect.fromLTRBXY(centerX + 15, centerY + 30, centerX + 20, centerY + 38, 2, 2),
      legPaint
    );
    
    // Larry's hooves
    final hoofPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 17.5, centerY + 38), width: 5, height: 3),
      hoofPaint
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 7.5, centerY + 38), width: 5, height: 3),
      hoofPaint
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 7.5, centerY + 38), width: 5, height: 3),
      hoofPaint
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 17.5, centerY + 38), width: 5, height: 3),
      hoofPaint
    );
    
    // Larry's tail
    final tailPath = Path();
    tailPath.moveTo(centerX + 25, centerY + 15);
    tailPath.quadraticBezierTo(centerX + 35, centerY + 10, centerX + 32, centerY + 5);
    canvas.drawPath(tailPath, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
    );
    
    // Tail tuft
    canvas.drawCircle(Offset(centerX + 32, centerY + 5), 2, snoutPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}