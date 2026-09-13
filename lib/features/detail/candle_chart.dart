import 'package:flutter/material.dart';

import '../../core/utils/price_format.dart';
import '../../data/models/candle.dart';
import '../../theme/theme.dart';

/// 캔들 차트. 꼬리(`chartBaseline`) + 몸통(`chartLineUp`/`chartLineDown`) + 우측 가격
/// 축 라벨(`chartAxisLabel`) + 하단 거래량 바(`chartVolumeBar`) + 종가선 아래 영역
/// 채우기(`chartAreaUp`/`chartAreaDown`)를 그린다. 그리드·크로스헤어·스케일 버튼은 없다.
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
        axisLabelColor: context.colors.chartAxisLabel,
        volumeBarColor: context.colors.chartVolumeBar,
        areaUpColor: context.colors.chartAreaUp,
        areaDownColor: context.colors.chartAreaDown,
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
    required this.axisLabelColor,
    required this.volumeBarColor,
    required this.areaUpColor,
    required this.areaDownColor,
  });

  final List<Candle> candles;
  final Color bullColor;
  final Color bearColor;

  /// 캔들 꼬리(고가-저가 선)와, 등락이 전혀 없는 캔들의 표시 색.
  final Color baselineColor;

  final Color axisLabelColor;
  final Color volumeBarColor;
  final Color areaUpColor;
  final Color areaDownColor;

  static const double _axisLabelWidth = 40;
  static const double _volumeHeightRatio = 0.2;
  static const double _priceVolumeGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final double chartWidth = size.width - _axisLabelWidth;
    final double volumeHeight = size.height * _volumeHeightRatio;
    final double priceHeight = size.height - volumeHeight - _priceVolumeGap;

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
        priceHeight - ((value - bottomValue) / valueRange) * priceHeight;

    final int maxVolume = candles
        .map((Candle c) => c.volume)
        .reduce((int a, int b) => a > b ? a : b);

    final double slotWidth = chartWidth / candles.length;
    final double bodyWidth = (slotWidth * 0.6).clamp(1.0, 20.0);

    _drawAreaFill(canvas, chartWidth, priceHeight, slotWidth, yFor);
    _drawVolumeBars(
      canvas,
      priceHeight + _priceVolumeGap,
      volumeHeight,
      slotWidth,
      bodyWidth,
      maxVolume,
    );

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

    _drawAxisLabels(canvas, chartWidth, priceHeight, topValue, bottomValue);
  }

  /// 종가를 잇는 선 아래를 채운다. 캔들별로 색을 나누지 않고, 구간 전체 등락 방향
  /// 하나로 통일한다(마지막 종가 vs 첫 종가) — 캔들 차트에 "영역 채우기"는 원래
  /// 라인 차트 개념이라 Figma에 정확한 스펙이 없는 선택 항목이라 가장 단순한 형태로 둠.
  void _drawAreaFill(
    Canvas canvas,
    double chartWidth,
    double priceHeight,
    double slotWidth,
    double Function(num) yFor,
  ) {
    final Path path = Path()..moveTo(0, priceHeight);
    for (int i = 0; i < candles.length; i++) {
      final double centerX = (i + 0.5) * slotWidth;
      path.lineTo(centerX, yFor(candles[i].close));
    }
    path
      ..lineTo(chartWidth, priceHeight)
      ..close();

    final bool isUpOverall = candles.last.close >= candles.first.close;
    canvas.drawPath(
      path,
      Paint()..color = isUpOverall ? areaUpColor : areaDownColor,
    );
  }

  void _drawVolumeBars(
    Canvas canvas,
    double top,
    double height,
    double slotWidth,
    double barWidth,
    int maxVolume,
  ) {
    if (maxVolume <= 0) return;
    final Paint paint = Paint()..color = volumeBarColor;
    for (int i = 0; i < candles.length; i++) {
      final double centerX = (i + 0.5) * slotWidth;
      final double barHeight = height * candles[i].volume / maxVolume;
      canvas.drawRect(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          top + (height - barHeight),
          barWidth,
          barHeight,
        ),
        paint,
      );
    }
  }

  void _drawAxisLabels(
    Canvas canvas,
    double chartWidth,
    double priceHeight,
    double topValue,
    double bottomValue,
  ) {
    final double midValue = (topValue + bottomValue) / 2;
    for (final (num value, double y) in <(num, double)>[
      (topValue, 0),
      (midValue, priceHeight / 2),
      (bottomValue, priceHeight),
    ]) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: formatPrice(value.round()),
          style: TextStyle(color: axisLabelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _axisLabelWidth - 4);
      final double dy = (y - painter.height / 2).clamp(0, priceHeight - painter.height);
      painter.paint(canvas, Offset(chartWidth + 4, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return !identical(oldDelegate.candles, candles) ||
        oldDelegate.bullColor != bullColor ||
        oldDelegate.bearColor != bearColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.axisLabelColor != axisLabelColor ||
        oldDelegate.volumeBarColor != volumeBarColor ||
        oldDelegate.areaUpColor != areaUpColor ||
        oldDelegate.areaDownColor != areaDownColor;
  }
}
