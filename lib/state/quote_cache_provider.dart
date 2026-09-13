import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/stock.dart';
import '../data/repositories/naver_stock_repository.dart';

part 'quote_cache_provider.g.dart';

/// 종목코드별 시세 캐시. 관심/상세 화면이 같은 심볼을 동시에 요청해도
/// 진행 중인 배치 조회가 있으면 그 결과를 공유해 API를 중복 호출하지 않는다.
@Riverpod(keepAlive: true)
class QuoteCache extends _$QuoteCache {
  Future<List<Stock>>? _inFlight;

  @override
  Map<String, Stock> build() => const <String, Stock>{};

  /// 캐시에 남아있는 마지막 시세. 배치 조회가 끝나기 전에도 화면에 우선 보여줄 때 쓴다.
  Stock? peek(String symbol) => state[symbol];

  /// [symbols] 전체 시세를 한 번에 조회해 캐시에 병합하고 반환한다.
  /// 이미 캐시된 심볼도 최신 값으로 덮어쓴다(관심 화면 새로고침 대응).
  Future<List<Stock>> refresh(List<String> symbols) {
    if (symbols.isEmpty) return Future.value(const <Stock>[]);

    final Future<List<Stock>>? inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    final Future<List<Stock>> future = ref
        .read(stockRepositoryProvider)
        .watchlistStocks(symbols)
        .then((stocks) {
          state = {
            ...state,
            for (final Stock stock in stocks) stock.symbol: stock,
          };
          return stocks;
        });
    _inFlight = future;
    future.whenComplete(() => _inFlight = null);
    return future;
  }
}
