import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../../core/utils/price_format.dart';
import '../../data/models/candle.dart';
import '../../theme/theme.dart';

/// 캔들 차트. 꼬리(`chartBaseline`) + 몸통(`chartLineUp`/`chartLineDown`) + 우측 가격
/// 축 라벨(`chartAxisLabel`) + 하단 거래량 바(`chartVolumeBar`) + 종가선 아래 영역
/// 채우기(`chartAreaUp`/`chartAreaDown`)를 그린다. 누르고 드래그하면 크로스헤어 +
/// OHLC 툴팁이 뜨고, 손을 떼면 사라진다. 그리드·스케일 버튼은 없다.
class CandleChart extends StatefulWidget {
  const CandleChart({super.key, required this.candles});

  final List<Candle> candles;

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  int? _hoverIndex;

  @override
  void didUpdateWidget(covariant CandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.candles, widget.candles)) {
      _hoverIndex = null;
    }
  }

  void _updateHover(Offset localPosition, double width, int candleCount) {
    final double chartWidth = width - _CandleChartPainter.axisLabelWidth;
    final double slotWidth = chartWidth / candleCount;
    final int index = (localPosition.dx / slotWidth).floor().clamp(
      0,
      candleCount - 1,
    );
    if (index != _hoverIndex) setState(() => _hoverIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // repository가 최신순으로 주므로, 왼쪽이 과거·오른쪽이 최신이 되도록 뒤집는다.
    final List<Candle> chronological = widget.candles.reversed.toList(
      growable: false,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GestureDetector(
          onPanDown: (DragDownDetails details) => _updateHover(
            details.localPosition,
            constraints.maxWidth,
            chronological.length,
          ),
          onPanUpdate: (DragUpdateDetails details) => _updateHover(
            details.localPosition,
            constraints.maxWidth,
            chronological.length,
          ),
          onPanEnd: (_) => setState(() => _hoverIndex = null),
          onPanCancel: () => setState(() => _hoverIndex = null),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _CandleChartPainter(
                    candles: chronological,
                    hoverIndex: _hoverIndex,
                    bullColor: context.colors.chartLineUp,
                    bearColor: context.colors.chartLineDown,
                    baselineColor: context.colors.chartBaseline,
                    axisLabelColor: context.colors.chartAxisLabel,
                    volumeBarColor: context.colors.chartVolumeBar,
                    areaUpColor: context.colors.chartAreaUp,
                    areaDownColor: context.colors.chartAreaDown,
                  ),
                ),
              ),
              if (_hoverIndex != null && _hoverIndex! < chronological.length)
                Positioned(
                  left: 0,
                  top: 0,
                  child: _OhlcTooltip(candle: chronological[_hoverIndex!]),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OhlcTooltip extends StatelessWidget {
  const _OhlcTooltip({required this.candle});

  final Candle candle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space3,
        vertical: context.dimens.space2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            formatMonthDay(candle.date),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 12,
              fontWeight: AppTypography.medium,
            ),
          ),
          SizedBox(height: context.dimens.space1),
          _OhlcRow(label: '시가', value: formatPrice(candle.open)),
          _OhlcRow(label: '고가', value: formatPrice(candle.high)),
          _OhlcRow(label: '저가', value: formatPrice(candle.low)),
          _OhlcRow(label: '종가', value: formatPrice(candle.close)),
          _OhlcRow(label: '거래량', value: formatPrice(candle.volume)),
        ],
      ),
    );
  }
}

class _OhlcRow extends StatelessWidget {
  const _OhlcRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$label ',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 11),
        ),
      ],
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  _CandleChartPainter({
    required this.candles,
    required this.hoverIndex,
    required this.bullColor,
    required this.bearColor,
    required this.baselineColor,
    required this.axisLabelColor,
    required this.volumeBarColor,
    required this.areaUpColor,
    required this.areaDownColor,
  });

  final List<Candle> candles;

  /// 눌러서 드래그 중인 캔들 인덱스. `null`이면 크로스헤어/툴팁을 안 그린다.
  final int? hoverIndex;

  final Color bullColor;
  final Color bearColor;

  /// 캔들 꼬리(고가-저가 선)와, 등락이 전혀 없는 캔들의 표시 색, 크로스헤어 선 색.
  final Color baselineColor;

  final Color axisLabelColor;
  final Color volumeBarColor;
  final Color areaUpColor;
  final Color areaDownColor;

  static const double axisLabelWidth = 40;
  static const double _volumeHeightRatio = 0.2;
  static const double _priceVolumeGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final double chartWidth = size.width - axisLabelWidth;
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

    final int? hovered = hoverIndex;
    if (hovered != null && hovered < candles.length) {
      final double centerX = (hovered + 0.5) * slotWidth;
      final double closeY = yFor(candles[hovered].close);
      final Paint crosshairPaint = Paint()
        ..color = baselineColor
        ..strokeWidth = 1;
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), crosshairPaint);
      canvas.drawLine(Offset(0, closeY), Offset(chartWidth, closeY), crosshairPaint);
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
      )..layout(maxWidth: axisLabelWidth - 4);
      final double dy = (y - painter.height / 2).clamp(0, priceHeight - painter.height);
      painter.paint(canvas, Offset(chartWidth + 4, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return !identical(oldDelegate.candles, candles) ||
        oldDelegate.hoverIndex != hoverIndex ||
        oldDelegate.bullColor != bullColor ||
        oldDelegate.bearColor != bearColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.axisLabelColor != axisLabelColor ||
        oldDelegate.volumeBarColor != volumeBarColor ||
        oldDelegate.areaUpColor != areaUpColor ||
        oldDelegate.areaDownColor != areaDownColor;
  }
}
