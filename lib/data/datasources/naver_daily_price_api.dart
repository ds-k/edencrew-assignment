import 'package:cp949_codec/cp949_codec.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../core/utils/json_coerce.dart';
import '../dto/daily_price_row_dto.dart';

/// `GET https://finance.naver.com/item/sise_day.naver?code={code}&page={page}`.
///
/// 응답이 JSON이 아니라 EUC-KR(CP949) 인코딩 HTML이라 디코딩과 DOM 파싱이 필요하다.
/// 한 페이지에 10거래일이 들어 있고, 이미 받은 페이지는 심볼+페이지 단위로 캐시해
/// 기간 탭을 바꿔도 재요청하지 않는다.
class NaverDailyPriceApi {
  NaverDailyPriceApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const int tradingDaysPerPage = 10;

  static final RegExp _datePattern = RegExp(r'^\d{4}\.\d{2}\.\d{2}$');
  static final RegExp _pagePattern = RegExp(r'page=(\d+)');

  /// `table.type2`의 데이터 행만 추출한다.
  ///
  /// `td`가 정확히 7개이고 첫 셀이 날짜 형식인 행만 채택 — 헤더(`th`만 있는 행)와
  /// 스페이서 행(`<td colspan="7">` 하나뿐)이 자연스럽게 걸러진다.
  /// 컬럼 순서 `[날짜, 종가, 전일비, 시가, 고가, 저가, 거래량]`에서 전일비(index 2)는 건너뛴다.
  static List<DailyPriceRowDto> parseRows(String html) {
    final document = html_parser.parse(html);
    final rows = <DailyPriceRowDto>[];
    for (final tr in document.querySelectorAll('table.type2 tr')) {
      final tds = tr.querySelectorAll('td');
      if (tds.length != 7) continue;
      final dateText = tds[0].text.trim();
      if (!_datePattern.hasMatch(dateText)) continue;
      rows.add(
        DailyPriceRowDto(
          localDate: dateText.replaceAll('.', ''),
          closePrice: asInt(tds[1].text) ?? 0,
          openPrice: asInt(tds[3].text) ?? 0,
          highPrice: asInt(tds[4].text) ?? 0,
          lowPrice: asInt(tds[5].text) ?? 0,
          accumulatedTradingVolume: asInt(tds[6].text) ?? 0,
        ),
      );
    }
    return rows;
  }

  /// `table.Nnavi` 안 모든 `a[href]`에서 `page=(\d+)`를 모아 최댓값을 반환한다.
  /// 못 찾으면 `1`.
  static int parseLastPage(String html) {
    final document = html_parser.parse(html);
    final nav = document.querySelector('table.Nnavi');
    if (nav == null) return 1;
    var lastPage = 1;
    for (final a in nav.querySelectorAll('a[href]')) {
      final href = a.attributes['href'] ?? '';
      final match = _pagePattern.firstMatch(href);
      if (match == null) continue;
      final page = int.parse(match.group(1)!);
      if (page > lastPage) lastPage = page;
    }
    return lastPage;
  }

  static DailyPricePage parseHtml(String html) =>
      DailyPricePage(rows: parseRows(html), lastPage: parseLastPage(html));

  final Map<String, Map<int, DailyPricePage>> _cache = {};

  /// 캐시 히트면 네트워크 요청 없이 반환한다.
  Future<DailyPricePage> fetchPage(String code, int page) async {
    final cached = _cache[code]?[page];
    if (cached != null) return cached;

    final uri = Uri.parse(
      'https://finance.naver.com/item/sise_day.naver?code=$code&page=$page',
    );
    final response = await _client.get(uri);
    final html = cp949.decode(response.bodyBytes);
    final result = parseHtml(html);

    _cache.putIfAbsent(code, () => {})[page] = result;
    return result;
  }

  /// 1페이지부터 순차로 받아 이어붙인다. 1페이지 응답의 `lastPage`로 상한을
  /// clamp해 `lastPage`를 넘는 페이지는 요청하지 않는다.
  Future<List<DailyPriceRowDto>> fetchRange(
    String code, {
    required int pageCount,
  }) async {
    final first = await fetchPage(code, 1);
    final upper = pageCount < first.lastPage ? pageCount : first.lastPage;

    final rows = <DailyPriceRowDto>[...first.rows];
    for (var page = 2; page <= upper; page++) {
      final result = await fetchPage(code, page);
      rows.addAll(result.rows);
    }
    return rows;
  }

  /// 새로고침이나 테스트에서 캐시를 비운다.
  void clearCache() => _cache.clear();
}
