import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/candle.dart';
import '../../../theme/theme.dart';
import '../candle_chart.dart';
import '../candles_provider.dart';

class ChartSection extends ConsumerWidget {
  const ChartSection({super.key, required this.symbol});

  final String symbol;

  /// 시안과 정확히 같을 필요는 없다(ASSIGNMENT.md) — 위아래 요소 배치만 어긋나지
  /// 않으면 되는 고정 높이.
  static const double _height = 220;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChartPeriod period = ref.watch(selectedPeriodProvider);
    final AsyncValue<List<Candle>> asyncCandles = ref.watch(
      candlesProvider(symbol, period),
    );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: asyncCandles.when(
        data: (List<Candle> candles) {
          if (candles.length < 2) {
            return Center(
              child: Text(
                '차트를 표시할 데이터가 부족합니다',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
            );
          }
          return CandleChart(candles: candles);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text(
            '차트를 불러오지 못했습니다',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
