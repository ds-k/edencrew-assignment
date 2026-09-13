import 'package:flutter/material.dart';

import '../../data/models/candle.dart';
import '../../theme/theme.dart';

/// 캔들 차트. 꼬리(`chartBaseline`) + 몸통(`chartLineUp`/`chartLineDown`)만 그린다.
/// 그리드·축 숫자·거래량·크로스헤어·스케일 버튼은 없다(좌우 폭을 꽉 채우는 순수 차트).
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
        baselineColor: context.colors.chartBaseline,
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  _CandleChartPainter({
    required this.candles,
    required this.bullColor,
    required this.bearColor,
    required this.baselineColor,
  });

  final List<Candle> candles;
  final Color bullColor;
  final Color bearColor;

  /// 캔들 꼬리(고가-저가 선)와, 등락이 전혀 없는 캔들의 표시 색.
  final Color baselineColor;

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

      // 고가==저가(그날 가격 변동이 전혀 없음)면 캔들 대신 짧은 기준선만 표시한다.
      if (candle.high == candle.low) {
        final double y = yFor(candle.close);
        canvas.drawLine(
          Offset(centerX - bodyWidth / 2, y),
          Offset(centerX + bodyWidth / 2, y),
          Paint()
            ..color = baselineColor
            ..strokeWidth = 2,
        );
        continue;
      }

      canvas.drawLine(
        Offset(centerX, yFor(candle.high)),
        Offset(centerX, yFor(candle.low)),
        Paint()
          ..color = baselineColor
          ..strokeWidth = 1,
      );

      final double openY = yFor(candle.open);
      final double closeY = yFor(candle.close);
      final double top = openY < closeY ? openY : closeY;
      final double bodyHeight = (openY - closeY).abs().clamp(1.0, double.infinity);

      canvas.drawRect(
        Rect.fromLTWH(centerX - bodyWidth / 2, top, bodyWidth, bodyHeight),
        Paint()..color = candle.isUp ? bullColor : bearColor,
      );
    }
  }



  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return !identical(oldDelegate.candles, candles) ||
        oldDelegate.bullColor != bullColor ||
        oldDelegate.bearColor != bearColor ||
        oldDelegate.baselineColor != baselineColor;
  }
}
