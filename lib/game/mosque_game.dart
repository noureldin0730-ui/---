import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MosqueGame extends FlameGame {
  double _time = 0;
  bool _adhanCalled = false;
  String _message = '';

  @override
  Color backgroundColor() => const Color(0xFF1A1410);

  @override
  Future<void> onLoad() async {
    // نضيف الأزرار
    add(AdhanButton(game: this)..priority = 10);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // لو الوقت عدى 5 ثواني، نخفي الرسالة
    if (_message.isNotEmpty && _time > 3) {
      _message = '';
      _time = 0;
    }
  }

  void callAdhan() {
    if (_adhanCalled) {
      _message = 'أذنت بالفعل';
      _time = 0;
      return;
    }
    _adhanCalled = true;
    _message = 'الله أكبر، الله أكبر...';
    _time = 0;
  }

  void resetAdhan() {
    _adhanCalled = false;
    _message = '';
    _time = 0;
  }

  @override
  void render(Canvas canvas) {
    // 1. السماء (خلفية)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A0F1A), // ليل
          Color(0xFF2A1F2A),
          Color(0xFF3A2F20),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    // 2. نجوم
    final starPaint = Paint()..color = Colors.white.withOpacity(0.7);
    for (int i = 0; i < 30; i++) {
      final x = (i * 137.5) % size.x;
      final y = (i * 73.3) % (size.y * 0.5);
      final r = ((i % 3) + 1).toDouble();
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // 3. القمر
    canvas.drawCircle(
      Offset(size.x - 100, 100),
      40,
      Paint()..color = const Color(0xFFFFF3D0),
    );
    canvas.drawCircle(
      Offset(size.x - 100, 100),
      40,
      Paint()
        ..color = const Color(0xFFFFF3D0).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // 4. الأرض
    final groundPaint = Paint()..color = const Color(0xFF3A2A1A);
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.75, size.x, size.y * 0.25),
      groundPaint,
    );

    // 5. الجامع — في النص
    _drawMosque(canvas, size.x / 2, size.y * 0.75);

    // 6. الرسالة — لو موجودة
    if (_message.isNotEmpty) {
      _drawMessage(canvas);
    }

    // 7. HUD
    _drawHud(canvas);
  }

  void _drawMosque(Canvas canvas, double cx, double baseY) {
    final wallColor = Paint()..color = const Color(0xFFE8DCC0);
    final wallShadow = Paint()..color = const Color(0xFFB8A88C);
    final domeColor = Paint()..color = const Color(0xFF7AB89A);
    final domeShadow = Paint()..color = const Color(0xFF4A8A6A);
    final doorColor = Paint()..color = const Color(0xFF8B5A2B);
    final gold = Paint()..color = const Color(0xFFFFD54A);

    // جسم الجامع
    final w = 240.0;
    final h = 160.0;
    canvas.drawRect(
      Rect.fromLTWH(cx - w / 2, baseY - h, w, h),
      wallColor,
    );

    // وش داكن على الجنب
    canvas.drawRect(
      Rect.fromLTWH(cx + w / 2 - 20, baseY - h, 20, h),
      wallShadow,
    );

    // القبة الكبيرة
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, baseY - h),
        width: 140,
        height: 100,
      ),
      math.pi,
      math.pi,
      true,
      domeColor,
    );
    // ظل القبة
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + 20, baseY - h),
        width: 100,
        height: 60,
      ),
      math.pi,
      math.pi / 2,
      true,
      domeShadow,
    );

    // رأس القبة
    canvas.drawCircle(Offset(cx, baseY - h - 55), 6, gold);

    // المأذنة
    final minaretX = cx - w / 2 - 30;
    canvas.drawRect(
      Rect.fromLTWH(minaretX - 15, baseY - h - 140, 30, 140 + h),
      wallColor,
    );
    // ظل المأذنة
    canvas.drawRect(
      Rect.fromLTWH(minaretX + 5, baseY - h - 140, 10, 140 + h),
      wallShadow,
    );
    // قبة المأذنة
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(minaretX, baseY - h - 140),
        width: 40,
        height: 40,
      ),
      math.pi,
      math.pi,
      true,
      domeColor,
    );
    // رأس المأذنة
    canvas.drawCircle(Offset(minaretX, baseY - h - 165), 5, gold);

    // مأذنة تانية (يمين)
    final minaret2X = cx + w / 2 + 30;
    canvas.drawRect(
      Rect.fromLTWH(minaret2X - 15, baseY - h - 120, 30, 120 + h),
      wallColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(minaret2X + 5, baseY - h - 120, 10, 120 + h),
      wallShadow,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(minaret2X, baseY - h - 120),
        width: 40,
        height: 40,
      ),
      math.pi,
      math.pi,
      true,
      domeColor,
    );
    canvas.drawCircle(Offset(minaret2X, baseY - h - 145), 5, gold);

    // الباب
    final doorW = 60.0;
    final doorH = 80.0;
    canvas.drawRect(
      Rect.fromLTWH(cx - doorW / 2, baseY - doorH, doorW, doorH),
      doorColor,
    );
    // قوس الباب
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, baseY - doorH),
        width: doorW,
        height: 40,
      ),
      math.pi,
      math.pi,
      true,
      doorColor,
    );

    // شبابيك
    final windowPaint = Paint()..color = const Color(0xFFFFE88A);
    // شباك شمال
    canvas.drawRect(
      Rect.fromLTWH(cx - 90, baseY - h + 40, 30, 40),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - 90, baseY - h + 40, 30, 40),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // شباك يمين
    canvas.drawRect(
      Rect.fromLTWH(cx + 60, baseY - h + 40, 30, 40),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + 60, baseY - h + 40, 30, 40),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // قوس فوق الباب (مقرنصات)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, baseY - h - 20),
        width: 100,
        height: 60,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = gold.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawMessage(Canvas canvas) {
    // خلفية الرسالة
    final text = _message;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFFFD54A),
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    final boxW = tp.width + 60;
    final boxH = tp.height + 40;
    final boxX = (size.x - boxW) / 2;
    final boxY = size.y * 0.2;

    // صندوق خلفي
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX, boxY, boxW, boxH),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.black.withOpacity(0.8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX, boxY, boxW, boxH),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xFFFFD54A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    tp.paint(canvas, Offset(boxX + 30, boxY + 20));
  }

  void _drawHud(Canvas canvas) {
    // شريط الحالة
    final text = _adhanCalled ? '✅ أذنت' : '⏳ لسه ما أذنتش';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, tp.width + 40, tp.height + 20),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    tp.paint(canvas, const Offset(40, 30));
  }
}

// ============================================================
// زرار "أذن"
// ============================================================
class AdhanButton extends PositionComponent with TapCallbacks {
  final MosqueGame game;
  bool _pressed = false;

  AdhanButton({required this.game}) : super();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // نحدد موقع الزرار في نص الشاشة تحت
    this.position = Vector2(size.x / 2 - 100, size.y - 100);
    this.size = Vector2(200, 60);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // خلفية الزرار
    final bgColor = game._adhanCalled
        ? const Color(0xFF4A8A4A)
        : const Color(0xFFFFD54A);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = bgColor,
    );

    // حدود
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // ظل داخلي (لو مضغوط)
    if (_pressed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()..color = Colors.black.withOpacity(0.2),
      );
    }

    // النص
    final label = game._adhanCalled ? '✅ أذنت' : '🕌 أذن';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    tp.paint(
      canvas,
      Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    if (game._adhanCalled) {
      game.resetAdhan();
    } else {
      game.callAdhan();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }
}