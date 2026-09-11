import 'dart:convert';
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
/// [requestedHosts]/[requestedUris]로 실제 요청 횟수·내용(특히 시세 배치 조회가
/// 심볼을 전부 한 쿼리에 담았는지)을 검증한다.
class _MockNaverServer {
  final List<String> requestedHosts = [];
  final List<Uri> requestedUris = [];

  http.Client get client => MockClient((request) async {
    requestedHosts.add(request.url.host);
    requestedUris.add(request.url);
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

      // 심볼 1개로는 "한 번에 일괄 조회"와 "종목별로 따로 호출"을 구분할 수
      // 없다(둘 다 요청 1회) — 2개 이상으로 호출해서 실제로 배치되는지 본다.
      final stocks = await repo.watchlistStocks(['005930', '000660']);

      final quoteUris = server.requestedUris
          .where((uri) => uri.host == 'polling.finance.naver.com')
          .toList();
      expect(quoteUris, hasLength(1));
      expect(
        quoteUris.single.queryParameters['query'],
        'SERVICE_ITEM:005930,000660',
      );

      final samsung = stocks.firstWhere((s) => s.symbol == '005930');
      expect(samsung.id, 'domestic:005930');
      expect(samsung.name, '삼성전자');
      expect(samsung.market, '코스피');
      expect(samsung.price, 269000);
      expect(samsung.priceChange, 0);
      expect(samsung.changeRate, closeTo(0.0, 1e-9));
      expect(samsung.open, 269000);
      expect(samsung.high, 270500);
      expect(samsung.low, 263500);
      expect(samsung.volume, 21010910);
      expect(samsung.marketCap, 269000 * 5846278608);
      expect(samsung.hasQuote, isTrue);
      expect(samsung.direction, PriceDirection.flat);

      final skHynix = stocks.firstWhere((s) => s.symbol == '000660');
      expect(skHynix.price, 1853000);
      expect(skHynix.hasQuote, isTrue);
    });

    test('등락 부호가 뒤집히지 않고 up/down/시세 미수신을 각각 올바르게 매핑한다', () async {
      // mock의 realtime_quote.json은 4종목이 전부 등락 0%라 up/down 분기가
      // 한 번도 실행되지 않는다 — 합성 응답으로 부호를 직접 검증한다.
      // 손으로 JSON 문자열을 쓰면 괄호를 놓치기 쉬워서 Map + jsonEncode로 만든다.
      Map<String, dynamic> quoteData(String symbol, int nv, int pcv) => {
        'cd': symbol,
        'nv': nv,
        'pcv': pcv,
        'ov': nv,
        'hv': nv,
        'lv': nv,
        'aq': 1000,
        'countOfListedStock': 10,
      };
      final quoteResponseBody = jsonEncode({
        'resultCode': 'success',
        'result': {
          'areas': [
            {
              'name': 'SERVICE_ITEM',
              'datas': [
                quoteData('005930', 110000, 100000),
                quoteData('000660', 90000, 100000),
              ],
            },
          ],
        },
      });

      final client = MockClient((request) async {
        if (request.url.host == 'polling.finance.naver.com') {
          return http.Response(quoteResponseBody, 200);
        }
        if (request.url.host == 'stock.naver.com') {
          return http.Response.bytes(
            File('assets/mock/stock_metadata.json').readAsBytesSync(),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final repo = NaverStockRepository(
        quoteApi: NaverQuoteApi(client: client),
        metadataApi: NaverMetadataApi(client: client),
      );

      // '035720'은 응답에 아예 없는 심볼 — 시세 미수신 경로.
      final stocks = await repo.watchlistStocks([
        '005930',
        '000660',
        '035720',
      ]);

      final up = stocks.firstWhere((s) => s.symbol == '005930');
      expect(up.priceChange, 10000); // nv - pcv, 부호 정방향
      expect(up.changeRate, closeTo(0.1, 1e-9));
      expect(up.direction, PriceDirection.up);
      expect(up.marketCap, 110000 * 10);

      final down = stocks.firstWhere((s) => s.symbol == '000660');
      expect(down.priceChange, -10000);
      expect(down.changeRate, closeTo(-0.1, 1e-9));
      expect(down.direction, PriceDirection.down);

      final noQuote = stocks.firstWhere((s) => s.symbol == '035720');
      expect(noQuote.hasQuote, isFalse);
      expect(noQuote.price, isNull);
      expect(noQuote.priceChange, isNull);
      expect(noQuote.changeRate, isNull);
      expect(noQuote.marketCap, isNull);
      expect(noQuote.direction, PriceDirection.flat);
      // 시세가 없어도 이름/시장은 메타데이터로부터 채워진다.
      expect(noQuote.name, isNotEmpty);
    });

    test('빈 목록은 네트워크 요청 없이 빈 리스트를 반환한다', () async {
      final server = _MockNaverServer();
      final repo = _repositoryWith(server);

      final stocks = await repo.watchlistStocks([]);

      expect(stocks, isEmpty);
      expect(server.requestedHosts, isEmpty);
    });

    test('한 심볼의 메타데이터 요청이 실패해도 나머지 종목은 정상 반환된다', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'polling.finance.naver.com') {
          return http.Response.bytes(
            File('assets/mock/realtime_quote.json').readAsBytesSync(),
            200,
          );
        }
        if (request.url.host == 'stock.naver.com') {
          // 000660의 메타데이터만 깨진 JSON으로 응답 — fetchMetadata가 예외를 던진다.
          if (request.url.path.endsWith('000660')) {
            return http.Response('not json', 200);
          }
          return http.Response.bytes(
            File('assets/mock/stock_metadata.json').readAsBytesSync(),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final repo = NaverStockRepository(
        quoteApi: NaverQuoteApi(client: client),
        metadataApi: NaverMetadataApi(client: client),
      );

      final stocks = await repo.watchlistStocks(['005930', '000660']);

      expect(stocks, hasLength(2));
      final samsung = stocks.firstWhere((s) => s.symbol == '005930');
      expect(samsung.name, '삼성전자');
      final skHynix = stocks.firstWhere((s) => s.symbol == '000660');
      // 메타데이터가 없어도 예외로 전체가 죽지 않고, 이름은 심볼로 대체된다.
      expect(skHynix.name, '000660');
      expect(skHynix.hasQuote, isTrue); // 시세는 정상 수신됨
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
