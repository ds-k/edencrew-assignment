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
      // 기간 탭을 바꾸면 이전 차트가 페이드아웃되며 새 차트가 페이드인된다.
      // period를 키로 써서 데이터가 바뀔 때만(로딩/에러 사이 전환은 말고) 애니메이션되게 한다.
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: asyncCandles.when(
          data: (List<Candle> candles) {
            if (candles.length < 2) {
              return Center(
                key: const ValueKey<String>('insufficient'),
                child: Text(
                  '차트를 표시할 데이터가 부족합니다',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                ),
              );
            }
            return KeyedSubtree(
              key: ValueKey<ChartPeriod>(period),
              child: CandleChart(candles: candles),
            );
          },
          loading: () => const Center(
            key: ValueKey<String>('loading'),
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => Center(
            key: const ValueKey<String>('error'),
            child: Text(
              '차트를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
