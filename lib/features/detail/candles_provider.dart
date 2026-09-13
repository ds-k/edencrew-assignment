import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/candle.dart';
import '../../data/repositories/naver_stock_repository.dart';

part 'candles_provider.g.dart';

/// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
///
/// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
/// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
/// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
@riverpod
Future<List<Candle>> candles(
  CandlesRef ref,
  String symbol,
  ChartPeriod period,
) {
  return ref.read(stockRepositoryProvider).candles(symbol, period);
}

/// 상세 화면에서 선택된 기간 탭. 화면이 하나만 떠 있고 autoDispose 기본값이라
/// 심볼별로 나눌 필요 없이(다음 상세 화면은 새로 `month1`부터 시작) 이 하나로 충분하다.
@riverpod
class SelectedPeriod extends _$SelectedPeriod {
  @override
  ChartPeriod build() => ChartPeriod.month1;

  void select(ChartPeriod period) => state = period;
}
