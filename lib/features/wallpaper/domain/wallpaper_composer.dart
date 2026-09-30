import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'entities/wallpaper_image.dart';

/// Everything needed to render one wallpaper.
class WallpaperSpec {
  const WallpaperSpec({
    required this.image,
    required this.quote,
    required this.template,
    required this.size,
    this.watermark = true,
    this.serifFamily = 'serif',
    this.sansFamily = 'sans-serif',
  });

  final ui.Image image;
  final WallpaperQuote quote;
  final WallpaperTemplate template;

  /// Output size in physical pixels (device resolution).
  final Size size;
  final bool watermark;
  final String serifFamily;
  final String sansFamily;
}

/// Renders a [WallpaperSpec] to PNG bytes. Pure `dart:ui`; safe to call from
/// widgets or an isolate-free background task.
class WallpaperComposer {
  const WallpaperComposer();

  Future<Uint8List> renderPng(WallpaperSpec spec) async {
    final image = await render(spec);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<ui.Image> render(WallpaperSpec spec) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, spec);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        spec.size.width.round(),
        spec.size.height.round(),
      );
    } finally {
      picture.dispose();
    }
  }

  /// Draws directly onto [canvas] sized to [spec.size]. Used by both the
  /// exporter and the live preview widget.
  void paint(Canvas canvas, WallpaperSpec spec) {
    final size = spec.size;
    _drawCover(canvas, spec.image, size);
    switch (spec.template) {
      case WallpaperTemplate.classic:
        _classic(canvas, spec);
      case WallpaperTemplate.lowerThird:
        _lowerThird(canvas, spec);
      case WallpaperTemplate.bold:
        _bold(canvas, spec);
      case WallpaperTemplate.card:
        _card(canvas, spec);
    }
    if (spec.watermark) _watermark(canvas, spec);
  }

  // ── Templates ─────────────────────────────────────────────────────────────

  void _classic(Canvas c, WallpaperSpec s) {
    final size = s.size;
    _scrim(
      c,
      size,
      const [0.0, 0.35, 0.65, 1.0],
      const [0.55, 0.25, 0.25, 0.6],
    );
    final maxW = size.width * 0.8;
    final quote = _fitText(
      '“${s.quote.text}”',
      maxWidth: maxW,
      maxHeight: size.height * 0.42,
      startSize: size.width * 0.062,
      minSize: size.width * 0.03,
      style: TextStyle(
        fontFamily: s.serifFamily,
        fontStyle: FontStyle.italic,
        color: const Color(0xFFFFFFFF),
        height: 1.35,
        shadows: _shadows,
      ),
      align: TextAlign.center,
    );
    final ref = _para(
      s.quote.attribution.toUpperCase(),
      maxWidth: maxW,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontSize: size.width * 0.028,
        letterSpacing: size.width * 0.004,
        color: const Color(0xE6FFFFFF),
        fontWeight: FontWeight.w600,
        shadows: _shadows,
      ),
      align: TextAlign.center,
    );
    final gap = size.height * 0.02;
    final total = quote.height + gap + ref.height;
    var y = (size.height - total) / 2 - size.height * 0.04;
    quote.paint(c, Offset((size.width - quote.width) / 2, y));
    y += quote.height + gap;
    _rule(c, Offset(size.width / 2, y - gap / 2), size.width * 0.08);
    ref.paint(c, Offset((size.width - ref.width) / 2, y));
  }

  void _lowerThird(Canvas c, WallpaperSpec s) {
    final size = s.size;
    _scrim(c, size, const [0.0, 0.45, 1.0], const [0.15, 0.2, 0.8]);
    final maxW = size.width * 0.82;
    final quote = _fitText(
      s.quote.text,
      maxWidth: maxW,
      maxHeight: size.height * 0.26,
      startSize: size.width * 0.052,
      minSize: size.width * 0.028,
      style: TextStyle(
        fontFamily: s.serifFamily,
        color: const Color(0xFFFFFFFF),
        height: 1.35,
        shadows: _shadows,
      ),
      align: TextAlign.left,
    );
    final ref = _para(
      s.quote.attribution,
      maxWidth: maxW,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontSize: size.width * 0.03,
        color: const Color(0xCCFFFFFF),
        fontWeight: FontWeight.w500,
        shadows: _shadows,
      ),
      align: TextAlign.left,
    );
    // Leave room for lock-screen shortcuts / home indicator.
    final bottom = size.height * 0.80;
    final x = (size.width - maxW) / 2;
    ref.paint(c, Offset(x, bottom - ref.height));
    quote.paint(
      c,
      Offset(x, bottom - ref.height - size.height * 0.015 - quote.height),
    );
  }

  void _bold(Canvas c, WallpaperSpec s) {
    final size = s.size;
    _scrim(c, size, const [0.0, 0.3, 1.0], const [0.1, 0.35, 0.9]);
    final maxW = size.width * 0.84;
    final quote = _fitText(
      s.quote.text,
      maxWidth: maxW,
      maxHeight: size.height * 0.40,
      startSize: size.width * 0.085,
      minSize: size.width * 0.036,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFFFFFFF),
        height: 1.12,
        letterSpacing: -size.width * 0.001,
        shadows: _shadows,
      ),
      align: TextAlign.left,
    );
    final ref = _para(
      s.quote.attribution.toUpperCase(),
      maxWidth: maxW,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontSize: size.width * 0.028,
        letterSpacing: size.width * 0.005,
        color: const Color(0xFFFFD166),
        fontWeight: FontWeight.w700,
        shadows: _shadows,
      ),
      align: TextAlign.left,
    );
    final x = (size.width - maxW) / 2;
    var y = size.height * 0.58 - quote.height / 2;
    y = y.clamp(size.height * 0.25, size.height * 0.78 - quote.height);
    quote.paint(c, Offset(x, y));
    // Accent bar.
    c.drawRect(
      Rect.fromLTWH(
        x,
        y + quote.height + size.height * 0.018,
        size.width * 0.12,
        size.height * 0.004,
      ),
      Paint()..color = const Color(0xFFFFD166),
    );
    ref.paint(c, Offset(x, y + quote.height + size.height * 0.035));
  }

  void _card(Canvas c, WallpaperSpec s) {
    final size = s.size;
    _scrim(c, size, const [0.0, 1.0], const [0.25, 0.35]);
    final cardW = size.width * 0.82;
    final pad = size.width * 0.07;
    final maxW = cardW - pad * 2;
    final quote = _fitText(
      s.quote.text,
      maxWidth: maxW,
      maxHeight: size.height * 0.34,
      startSize: size.width * 0.05,
      minSize: size.width * 0.028,
      style: TextStyle(
        fontFamily: s.serifFamily,
        color: const Color(0xFFFFFFFF),
        height: 1.4,
      ),
      align: TextAlign.center,
    );
    final ref = _para(
      s.quote.attribution,
      maxWidth: maxW,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontSize: size.width * 0.03,
        color: const Color(0xD9FFFFFF),
        fontWeight: FontWeight.w600,
      ),
      align: TextAlign.center,
    );
    final gap = size.height * 0.018;
    final cardH = pad * 2 + quote.height + gap + ref.height;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.5),
      width: cardW,
      height: cardH,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width * 0.04),
    );
    c.drawRRect(
      rrect.shift(Offset(0, size.height * 0.006)),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02),
    );
    c.drawRRect(rrect, Paint()..color = const Color(0x66000000));
    c.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.002
        ..color = const Color(0x40FFFFFF),
    );
    var y = rect.top + pad;
    quote.paint(c, Offset(rect.left + (cardW - quote.width) / 2, y));
    y += quote.height + gap;
    ref.paint(c, Offset(rect.left + (cardW - ref.width) / 2, y));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static const _shadows = [
    Shadow(color: Color(0x99000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  void _drawCover(Canvas c, ui.Image img, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final scale = math.max(size.width / img.width, size.height / img.height);
    final w = img.width * scale, h = img.height * scale;
    final dst = Rect.fromLTWH(
      (size.width - w) / 2,
      (size.height - h) / 2,
      w,
      h,
    );
    c.drawImageRect(img, src, dst, Paint()..filterQuality = FilterQuality.high);
  }

  void _scrim(Canvas c, Size size, List<double> stops, List<double> alphas) {
    assert(stops.length == alphas.length);
    final colors = [
      for (final a in alphas) Color.fromRGBO(0, 0, 0, a.clamp(0.0, 1.0)),
    ];
    final rect = Offset.zero & size;
    c.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          colors,
          stops,
        ),
    );
  }

  void _rule(Canvas c, Offset center, double width) {
    c.drawLine(
      center - Offset(width / 2, 0),
      center + Offset(width / 2, 0),
      Paint()
        ..color = const Color(0xB3FFFFFF)
        ..strokeWidth = 2,
    );
  }

  void _watermark(Canvas c, WallpaperSpec s) {
    final size = s.size;
    final p = _para(
      'Verse Bible',
      maxWidth: size.width,
      style: TextStyle(
        fontFamily: s.sansFamily,
        fontSize: size.width * 0.022,
        color: const Color(0x80FFFFFF),
        fontWeight: FontWeight.w500,
        letterSpacing: size.width * 0.002,
      ),
      align: TextAlign.center,
    );
    p.paint(c, Offset((size.width - p.width) / 2, size.height * 0.94));
  }

  /// Shrinks font size until text fits within [maxWidth] × [maxHeight].
  TextPainter _fitText(
    String text, {
    required double maxWidth,
    required double maxHeight,
    required double startSize,
    required double minSize,
    required TextStyle style,
    required TextAlign align,
  }) {
    var fontSize = startSize;
    late TextPainter tp;
    while (true) {
      tp = _para(
        text,
        maxWidth: maxWidth,
        style: style.copyWith(fontSize: fontSize),
        align: align,
      );
      if (tp.height <= maxHeight || fontSize <= minSize) break;
      fontSize = math.max(minSize, fontSize * 0.92);
    }
    if (tp.height > maxHeight) {
      // Still too tall at minimum size: hard-clip with ellipsis.
      final maxLines = math.max(
        1,
        (maxHeight / (fontSize * (style.height ?? 1.2))).floor(),
      );
      tp = _para(
        text,
        maxWidth: maxWidth,
        style: style.copyWith(fontSize: fontSize),
        align: align,
        maxLines: maxLines,
      );
    }
    return tp;
  }

  TextPainter _para(
    String text, {
    required double maxWidth,
    required TextStyle style,
    required TextAlign align,
    int? maxLines,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    )..layout(maxWidth: maxWidth);
    return tp;
  }
}
