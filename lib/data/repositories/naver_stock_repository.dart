import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../datasources/naver_daily_price_api.dart';
import '../datasources/naver_metadata_api.dart';
import '../datasources/naver_quote_api.dart';
import '../datasources/naver_search_api.dart';
import '../dto/realtime_quote_dto.dart';
import '../dto/search_suggestion_dto.dart';
import '../dto/stock_metadata_dto.dart';
import '../models/candle.dart';
import '../models/search_result.dart';
import '../models/stock.dart';
import 'stock_repository.dart';

part 'naver_stock_repository.g.dart';

/// 화면 전역에서 공유하는 [StockRepository] 인스턴스.
@Riverpod(keepAlive: true)
StockRepository stockRepository(StockRepositoryRef ref) =>
    NaverStockRepository();

class NaverStockRepository implements StockRepository {
  NaverStockRepository({
    NaverSearchApi? searchApi,
    NaverQuoteApi? quoteApi,
    NaverMetadataApi? metadataApi,
    NaverDailyPriceApi? dailyPriceApi,
  }) : _searchApi = searchApi ?? NaverSearchApi(),
       _quoteApi = quoteApi ?? NaverQuoteApi(),
       _metadataApi = metadataApi ?? NaverMetadataApi(),
       _dailyPriceApi = dailyPriceApi ?? NaverDailyPriceApi();

  final NaverSearchApi _searchApi;
  final NaverQuoteApi _quoteApi;
  final NaverMetadataApi _metadataApi;
  final NaverDailyPriceApi _dailyPriceApi;

  static final RegExp _domesticSymbolPattern = RegExp(r'^\d{6}$');

  @override
  Future<List<SearchResult>> search(String query) async {
    final SearchAutocompleteDto dto = await _searchApi.autocomplete(query);
    return [
      for (final item in dto.items)
        if (_isDomesticStock(item)) _toSearchResult(item),
    ];
  }

  bool _isDomesticStock(SearchSuggestionDto item) {
    final String? code = item.code;
    return item.category == 'stock' &&
        item.nationCode == 'KOR' &&
        code != null &&
        _domesticSymbolPattern.hasMatch(code);
  }

  SearchResult _toSearchResult(SearchSuggestionDto item) {
    final String code = item.code!;
    return SearchResult(
      id: 'domestic:$code',
      symbol: code,
      name: item.name ?? '',
      market: item.typeName ?? '',
    );
  }

  @override
  Future<List<Stock>> watchlistStocks(List<String> symbols) async {
    if (symbols.isEmpty) return const <Stock>[];

    final Future<List<RealtimeQuoteDto>> quotesFuture = _quoteApi.fetchQuotes(
      symbols,
    );
    final Future<List<StockMetadataDto>> metadataFuture = Future.wait(
      symbols.map(_fetchMetadataOrEmpty),
    );

    final List<RealtimeQuoteDto> quotes = await quotesFuture;
    final List<StockMetadataDto> metadataList = await metadataFuture;

    final Map<String, RealtimeQuoteDto> quoteBySymbol = {
      for (final RealtimeQuoteDto quote in quotes) quote.symbol: quote,
    };

    return [
      for (var i = 0; i < symbols.length; i++)
        _toStock(symbols[i], metadataList[i], quoteBySymbol[symbols[i]]),
    ];
  }

  /// 심볼 하나의 메타데이터 요청이 실패해도 나머지 종목까지 통째로 실패하지 않도록 격리한다
  Future<StockMetadataDto> _fetchMetadataOrEmpty(String symbol) async {
    try {
      return await _metadataApi.fetchMetadata(symbol);
    } catch (_) {
      return const StockMetadataDto();
    }
  }

  Stock _toStock(
    String symbol,
    StockMetadataDto metadata,
    RealtimeQuoteDto? quote,
  ) {
    final int? price = quote?.currentPrice;
    final int? previousClose = quote?.previousClose;
    final int? priceChange = (price != null && previousClose != null)
        ? price - previousClose
        : null;
    final double? changeRate =
        (priceChange != null && previousClose != null && previousClose != 0)
        ? priceChange / previousClose
        : null;
    final int? listedShareCount = quote?.listedShareCount;
    final int? marketCap = (price != null && listedShareCount != null)
        ? price * listedShareCount
        : null;

    return Stock(
      id: 'domestic:$symbol',
      symbol: symbol,
      name: metadata.stockName ?? symbol,
      market: metadata.exchangeNameKor ?? '',
      price: price,
      priceChange: priceChange,
      changeRate: changeRate,
      open: quote?.open,
      high: quote?.high,
      low: quote?.low,
      volume: quote?.accumulatedVolume,
      marketCap: marketCap,
    );
  }

  @override
  Future<Stock> stockDetail(String symbol) async {
    final List<Stock> stocks = await watchlistStocks([symbol]);
    return stocks.first;
  }

  @override
  Future<List<Candle>> candles(String symbol, ChartPeriod period) async {
    final rows = await _dailyPriceApi.fetchRange(
      symbol,
      pageCount: period.pageCount,
    );
    // Naver 응답이 이미 최신순이라 재정렬하지 않는다 — candlesticks 패키지도 이 순서를 기대함.
    return rows.map(Candle.fromDto).toList(growable: false);
  }
}
