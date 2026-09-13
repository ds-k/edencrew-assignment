import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/stock.dart';
import '../data/repositories/naver_stock_repository.dart';

part 'quote_cache_provider.g.dart';

/// 종목코드별 시세 캐시. 관심/상세 화면이 같은 심볼을 동시에 요청해도
/// 진행 중인 배치 조회가 있으면 그 결과를 공유해 API를 중복 호출하지 않는다.
@Riverpod(keepAlive: true)
class QuoteCache extends _$QuoteCache {
  List<String>? _inFlightSymbols;
  Future<List<Stock>>? _inFlight;

  @override
  Map<String, Stock> build() => const <String, Stock>{};

  /// 캐시에 남아있는 마지막 시세. 배치 조회가 끝나기 전에도 화면에 우선 보여줄 때 쓴다.
  Stock? peek(String symbol) => state[symbol];

  /// [symbols] 전체 시세를 한 번에 조회해 캐시에 병합하고 반환한다.
  /// 이미 캐시된 심볼도 최신 값으로 덮어쓴다(관심 화면 새로고침 대응).
  ///
  /// 진행 중인 요청과 [symbols] 구성이 같을 때만 그 결과를 공유한다 — 심볼 집합이
  /// 다르면(예: 관심 등록 도중 새 종목이 추가됨) 별도로 요청해서 새 종목이 누락되지 않게 한다.
  Future<List<Stock>> refresh(List<String> symbols) {
    if (symbols.isEmpty) return Future.value(const <Stock>[]);

    final List<String> sorted = List<String>.of(symbols)..sort();
    final Future<List<Stock>>? inFlight = _inFlight;
    if (inFlight != null && _sameSymbols(_inFlightSymbols, sorted)) {
      return inFlight;
    }

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
    _inFlightSymbols = sorted;
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
        _inFlightSymbols = null;
      }
    });
    return future;
  }
}

bool _sameSymbols(List<String>? a, List<String> b) {
  if (a == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
