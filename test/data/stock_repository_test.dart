import 'dart:io';

import 'package:edencrew_assignment_starter/data/datasources/naver_daily_price_api.dart';
import 'package:edencrew_assignment_starter/data/datasources/naver_metadata_api.dart';
import 'package:edencrew_assignment_starter/data/datasources/naver_quote_api.dart';
import 'package:edencrew_assignment_starter/data/datasources/naver_search_api.dart';
import 'package:edencrew_assignment_starter/data/models/candle.dart';
import 'package:edencrew_assignment_starter/data/models/stock.dart';
import 'package:edencrew_assignment_starter/data/repositories/naver_stock_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 4개 endpoint를 호스트로 분기해 mock 자산 파일을 그대로 돌려주는 가짜 서버.
/// [requestedHosts]로 실제 요청 횟수(특히 시세 배치 조회)를 검증한다.
class _MockNaverServer {
  final List<String> requestedHosts = [];

  http.Client get client => MockClient((request) async {
    requestedHosts.add(request.url.host);
    switch (request.url.host) {
      case 'ac.stock.naver.com':
        final query = request.url.queryParameters['q'];
        final file = query == '애플'
            ? 'search_autocomplete_mixed.json'
            : 'search_autocomplete.json';
        return http.Response.bytes(
          File('assets/mock/$file').readAsBytesSync(),
          200,
        );
      case 'polling.finance.naver.com':
        return http.Response.bytes(
          File('assets/mock/realtime_quote.json').readAsBytesSync(),
          200,
        );
      case 'stock.naver.com':
        return http.Response.bytes(
          File('assets/mock/stock_metadata.json').readAsBytesSync(),
          200,
        );
      case 'finance.naver.com':
        return http.Response.bytes(
          File('assets/mock/daily_price.html').readAsBytesSync(),
          200,
        );
      default:
        return http.Response('not found', 404);
    }
  });
}

NaverStockRepository _repositoryWith(_MockNaverServer server) {
  final http.Client client = server.client;
  return NaverStockRepository(
    searchApi: NaverSearchApi(client: client),
    quoteApi: NaverQuoteApi(client: client),
    metadataApi: NaverMetadataApi(client: client),
    dailyPriceApi: NaverDailyPriceApi(client: client),
  );
}

void main() {
  group('NaverStockRepository.search', () {
    test('국내 6자리 종목만 통과시키고 canonical id를 만든다', () async {
      final repo = _repositoryWith(_MockNaverServer());

      final results = await repo.search('삼성');

      expect(results, isNotEmpty);
      expect(results.every((r) => r.id.startsWith('domestic:')), isTrue);
      expect(
        results.every((r) => RegExp(r'^\d{6}$').hasMatch(r.symbol)),
        isTrue,
      );

      final first = results.first;
      expect(first.id, 'domestic:005930');
      expect(first.symbol, '005930');
      expect(first.name, '삼성전자');
      expect(first.market, '코스피');
    });

    test('해외 종목/비정형 코드는 전부 걸러진다', () async {
      final repo = _repositoryWith(_MockNaverServer());

      final results = await repo.search('애플');

      expect(results, isEmpty);
    });
  });

  group('NaverStockRepository.watchlistStocks', () {
    test('시세는 심볼 전체를 한 번의 요청으로만 가져와 dto 값을 그대로 매핑한다', () async {
      final server = _MockNaverServer();
      final repo = _repositoryWith(server);

      final stocks = await repo.watchlistStocks(['005930']);

      final quoteRequestCount = server.requestedHosts
          .where((host) => host == 'polling.finance.naver.com')
          .length;
      expect(quoteRequestCount, 1);

      final stock = stocks.single;
      expect(stock.id, 'domestic:005930');
      expect(stock.name, '삼성전자');
      expect(stock.market, '코스피');
      expect(stock.price, 269000);
      expect(stock.priceChange, 0);
      expect(stock.changeRate, closeTo(0.0, 1e-9));
      expect(stock.open, 269000);
      expect(stock.high, 270500);
      expect(stock.low, 263500);
      expect(stock.volume, 21010910);
      expect(stock.marketCap, 269000 * 5846278608);
      expect(stock.hasQuote, isTrue);
      expect(stock.direction, PriceDirection.flat);
    });

    test('빈 목록은 네트워크 요청 없이 빈 리스트를 반환한다', () async {
      final server = _MockNaverServer();
      final repo = _repositoryWith(server);

      final stocks = await repo.watchlistStocks([]);

      expect(stocks, isEmpty);
      expect(server.requestedHosts, isEmpty);
    });
  });

  group('NaverStockRepository.stockDetail', () {
    test('watchlistStocks를 재사용해 단건을 반환한다', () async {
      final repo = _repositoryWith(_MockNaverServer());

      final stock = await repo.stockDetail('005930');

      expect(stock.symbol, '005930');
      expect(stock.price, 269000);
    });
  });

  group('NaverStockRepository.candles', () {
    test('기간 탭의 pageCount만큼 페이지를 이어붙이고 재정렬하지 않는다', () async {
      final repo = _repositoryWith(_MockNaverServer());

      final candles = await repo.candles('005930', ChartPeriod.month1);

      expect(candles, hasLength(ChartPeriod.month1.pageCount * 10));
      // 재정렬하지 않으므로 첫 캔들이 mock의 최신 날짜(2026.09.10)와 같다.
      expect(candles.first.date, DateTime(2026, 9, 10));
      expect(candles.first.close, 269000);
      expect(candles.first.isUp, isTrue); // close(269000) >= open(269000)
    });
  });
}
