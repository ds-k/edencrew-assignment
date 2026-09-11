import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:edencrew_assignment_starter/core/network/naver_http_client.dart';
import 'package:edencrew_assignment_starter/data/datasources/naver_daily_price_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// `assets/mock/daily_price.html`을 실제 응답과 동일하게 EUC-KR(CP949)로 디코딩한다.
String _loadMockHtml() {
  final List<int> bytes = File('assets/mock/daily_price.html').readAsBytesSync();
  return cp949.decode(bytes);
}

/// 캐시/clamp 테스트용 합성 페이지. 한글 없이 ASCII로만 구성해 인코딩과 무관하게
/// 검증한다. `lastPage`는 페이지 네비게이션에 심어서 clamp 동작을 제어한다.
String _fakePageHtml({required int page, required int lastPage}) {
  return '''
<table class="type2">
<tr><th>date</th><th>close</th><th>diff</th><th>open</th><th>high</th><th>low</th><th>volume</th></tr>
<tr><td colspan="7" height="8"></td></tr>
<tr>
<td align="center"><span>2026.01.0$page</span></td>
<td class="num"><span>${page}0,000</span></td>
<td class="num"><span>0</span></td>
<td class="num"><span>${page}0,000</span></td>
<td class="num"><span>${page}0,500</span></td>
<td class="num"><span>${page}0,000</span></td>
<td class="num"><span>1,000,000</span></td>
</tr>
<tr><td colspan="7" height="8"></td></tr>
</table>
<table class="Nnavi">
<tr>
<td><a href="/item/sise_day.naver?code=005930&page=1">1</a></td>
<td><a href="/item/sise_day.naver?code=005930&page=$lastPage">last</a></td>
</tr>
</table>
''';
}

void main() {
  group('NaverDailyPriceApi.parseRows / parseLastPage (실제 mock HTML)', () {
    final String html = _loadMockHtml();

    test('EUC-KR 디코딩이 한글을 깨뜨리지 않는다', () {
      expect(html, contains('저가'));
      expect(html, contains('다음'));
      expect(html, contains('맨뒤'));
    });

    test('헤더/스페이서 행을 제외하고 데이터 행 10개만 남는다', () {
      expect(NaverDailyPriceApi.parseRows(html), hasLength(10));
    });

    test('컬럼을 올바른 필드에 매핑하고 숫자의 쉼표를 제거한다', () {
      final first = NaverDailyPriceApi.parseRows(html).first;
      expect(first.localDate, '20260910');
      expect(first.closePrice, 269000);
      expect(first.openPrice, 269000);
      expect(first.highPrice, 270500);
      expect(first.lowPrice, 263500);
      expect(first.accumulatedTradingVolume, 21010910);
    });

    test('페이지 네비게이션의 "맨뒤" 링크에서 마지막 페이지를 읽는다', () {
      expect(NaverDailyPriceApi.parseLastPage(html), 756);
    });

    test('parseHtml은 parseRows + parseLastPage를 그대로 조합한다', () {
      final page = NaverDailyPriceApi.parseHtml(html);
      expect(page.rows, hasLength(10));
      expect(page.lastPage, 756);
    });
  });

  group('NaverDailyPriceApi.parseRows 숫자 파싱 실패 처리', () {
    test('숫자로 못 읽는 셀이 있는 행은 0으로 채우지 않고 건너뛴다', () {
      const html = '''
<table class="type2">
<tr><th>date</th><th>close</th><th>diff</th><th>open</th><th>high</th><th>low</th><th>volume</th></tr>
<tr>
<td align="center"><span>2026.01.02</span></td>
<td class="num"><span>-</span></td>
<td class="num"><span>0</span></td>
<td class="num"><span>10,000</span></td>
<td class="num"><span>10,500</span></td>
<td class="num"><span>9,500</span></td>
<td class="num"><span>1,000</span></td>
</tr>
<tr>
<td align="center"><span>2026.01.01</span></td>
<td class="num"><span>10,000</span></td>
<td class="num"><span>0</span></td>
<td class="num"><span>10,000</span></td>
<td class="num"><span>10,500</span></td>
<td class="num"><span>9,500</span></td>
<td class="num"><span>1,000</span></td>
</tr>
</table>
''';

      final rows = NaverDailyPriceApi.parseRows(html);

      // 종가가 "-"라 파싱 실패한 01.02 행은 closePrice=0으로 위장되지 않고
      // 아예 빠져야 한다. 정상 행(01.01)만 남는다.
      expect(rows, hasLength(1));
      expect(rows.single.localDate, '20260101');
    });
  });

  group('NaverDailyPriceApi 페이지 캐시 / lastPage clamp', () {
    test('이미 받은 페이지는 재요청하지 않는다', () async {
      final requestedPages = <int>[];
      final client = MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page']!);
        requestedPages.add(page);
        return http.Response.bytes(
          ascii.encode(_fakePageHtml(page: page, lastPage: 10)),
          200,
        );
      });
      final api = NaverDailyPriceApi(client: client);

      final rows = await api.fetchRange('005930', pageCount: 2);
      expect(rows, hasLength(2));
      expect(requestedPages, <int>[1, 2]);

      // 같은 범위를 다시 조회 — 전부 캐시 히트라 네트워크 요청이 없다.
      requestedPages.clear();
      await api.fetchRange('005930', pageCount: 2);
      expect(requestedPages, isEmpty);

      // 범위를 넓히면 새로 필요한 페이지만 요청한다.
      await api.fetchRange('005930', pageCount: 3);
      expect(requestedPages, <int>[3]);
    });

    test('lastPage보다 큰 페이지는 요청하지 않는다', () async {
      final requestedPages = <int>[];
      final client = MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page']!);
        requestedPages.add(page);
        return http.Response.bytes(
          ascii.encode(_fakePageHtml(page: page, lastPage: 1)),
          200,
        );
      });
      final api = NaverDailyPriceApi(client: client);

      final rows = await api.fetchRange('005930', pageCount: 5);
      expect(rows, hasLength(1));
      expect(requestedPages, <int>[1]);
    });

    test('clearCache 이후에는 다시 네트워크를 탄다', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        final page = int.parse(request.url.queryParameters['page']!);
        return http.Response.bytes(
          ascii.encode(_fakePageHtml(page: page, lastPage: 1)),
          200,
        );
      });
      final api = NaverDailyPriceApi(client: client);

      await api.fetchPage('005930', 1);
      await api.fetchPage('005930', 1);
      expect(requestCount, 1);

      api.clearCache();
      await api.fetchPage('005930', 1);
      expect(requestCount, 2);
    });
  });

  group('NaverDailyPriceApi 상태코드 검사', () {
    test('200이 아니면 예외를 던지고 캐시하지 않는다', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response('blocked', 503);
      });
      final api = NaverDailyPriceApi(client: client);

      await expectLater(
        () => api.fetchPage('005930', 1),
        throwsA(isA<NaverHttpException>()),
      );
      expect(callCount, 1);

      // 실패 응답이 캐시에 안 남아있어야 다시 호출했을 때도 네트워크를 탄다.
      await expectLater(
        () => api.fetchPage('005930', 1),
        throwsA(isA<NaverHttpException>()),
      );
      expect(callCount, 2);
    });
  });
}
