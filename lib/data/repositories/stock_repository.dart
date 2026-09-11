import '../models/candle.dart';
import '../models/search_result.dart';
import '../models/stock.dart';

/// 화면이 의존하는 데이터 계층 경계. impl을 fake로 교체해 화면/테스트에서 mock 가능.
abstract class StockRepository {
  /// 검색어로 국내 주식만 필터링한 결과.
  Future<List<SearchResult>> search(String query);

  /// 관심/상세 화면 공통 진입점. 시세는 항상 `symbols` 전체를 한 번에 조회한다.
  Future<List<Stock>> watchlistStocks(List<String> symbols);

  /// 상세 화면 단건 조회. 내부적으로 [watchlistStocks]를 재사용한다.
  Future<Stock> stockDetail(String symbol);

  /// 기간 탭에 해당하는 일별 시세. 최신 날짜가 먼저 오는 순서 그대로 반환한다.
  Future<List<Candle>> candles(String symbol, ChartPeriod period);
}
