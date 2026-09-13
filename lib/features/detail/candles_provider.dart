import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/candle.dart';
import '../../data/repositories/naver_stock_repository.dart';

part 'candles_provider.g.dart';

/// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
@riverpod
Future<List<Candle>> monthlyCandles(MonthlyCandlesRef ref, String symbol) {
  return ref.read(stockRepositoryProvider).candles(symbol, ChartPeriod.month1);
}
