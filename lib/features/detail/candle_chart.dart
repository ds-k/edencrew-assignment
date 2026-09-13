import 'package:flutter/material.dart';

import '../../data/models/candle.dart';
import '../../theme/theme.dart';

/// 그리드/축/거래량/스케일 버튼 없이 캔들만 그리는 차트. 좌우 폭을 꽉 채운다.
///
/// `candlesticks` 3.0.1 패키지는 이런 요소들을 끌 수 있는 옵션이 없이 항상 같이
/// 그려서(`ChartComposer`/`MainChartPane`에 하드코딩) 직접 `CustomPainter`로
/// 그리는 쪽을 택했다 — ASSIGNMENT.md가 명시적으로 허용하는 방식이다.
class CandleChart extends StatelessWidget {
  const CandleChart({super.key, required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    // repository가 최신순으로 주므로, 왼쪽이 과거·오른쪽이 최신이 되도록 뒤집는다.
    final List<Candle> chronological = candles.reversed.toList(growable: false);

    return CustomPaint(
      size: Size.infinite,
      painter: _CandleChartPainter(
        candles: chronological,
        bullColor: context.colors.chartLineUp,
        bearColor: context.colors.chartLineDown,
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  _CandleChartPainter({
    required this.candles,
    required this.bullColor,
    required this.bearColor,
  });

  final List<Candle> candles;
  final Color bullColor;
  final Color bearColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final int high = candles.map((Candle c) => c.high).reduce(
      (int a, int b) => a > b ? a : b,
    );
    final int low = candles.map((Candle c) => c.low).reduce(
      (int a, int b) => a < b ? a : b,
    );
    final double padding = (high - low) * 0.1;
    final double topValue = high + padding;
    final double bottomValue = low - padding;
    final double valueRange = topValue == bottomValue ? 1 : topValue - bottomValue;

    double yFor(num value) =>
        size.height - ((value - bottomValue) / valueRange) * size.height;

    final double slotWidth = size.width / candles.length;
    final double bodyWidth = (slotWidth * 0.6).clamp(1.0, 20.0);

    for (int i = 0; i < candles.length; i++) {
      final Candle candle = candles[i];
      final double centerX = (i + 0.5) * slotWidth;
      final Paint paint = Paint()
        ..color = candle.isUp ? bullColor : bearColor
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(centerX, yFor(candle.high)),
        Offset(centerX, yFor(candle.low)),
        paint,
      );

      final double openY = yFor(candle.open);
      final double closeY = yFor(candle.close);
      final double top = openY < closeY ? openY : closeY;
      final double bodyHeight = (openY - closeY).abs().clamp(1.0, double.infinity);

      canvas.drawRect(
        Rect.fromLTWH(centerX - bodyWidth / 2, top, bodyWidth, bodyHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return !identical(oldDelegate.candles, candles) ||
        oldDelegate.bullColor != bullColor ||
        oldDelegate.bearColor != bearColor;
  }
}
