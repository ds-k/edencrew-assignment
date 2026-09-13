import 'package:cp949_codec/cp949_codec.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../core/network/naver_http_client.dart';
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
  /// 컬럼 순서는 `[날짜, 종가, 전일비, 시가, 고가, 저가, 거래량]`.
  static List<DailyPriceRowDto> parseRows(String html) =>
      _rowsFrom(html_parser.parse(html));

  /// `table.Nnavi` 안 모든 `a[href]`에서 `page=(\d+)`를 모아 최댓값을 반환한다.
  /// 못 찾으면 `1`.
  static int parseLastPage(String html) => _lastPageFrom(html_parser.parse(html));

  /// [parseRows] + [parseLastPage]를 합친 결과. HTML을 한 번만 파싱해서 조합한다
  /// (두 메서드를 따로 부르면 같은 문자열을 두 번 DOM 파싱하게 된다).
  static DailyPricePage parseHtml(String html) {
    final document = html_parser.parse(html);
    return DailyPricePage(
      rows: _rowsFrom(document),
      lastPage: _lastPageFrom(document),
    );
  }

  static List<DailyPriceRowDto> _rowsFrom(dom.Document document) {
    final rows = <DailyPriceRowDto>[];
    for (final tr in document.querySelectorAll('table.type2 tr')) {
      final tds = tr.querySelectorAll('td');
      if (tds.length != 7) continue;
      final dateText = tds[0].text.trim();
      if (!_datePattern.hasMatch(dateText)) continue;

      // 숫자 파싱에 실패하면 0으로 채우지 않고 행 자체를 건너뛴다 — json_coerce의
      // "실패 시 null, 해석은 상위 계층 몫" 계약을 어기고 조용히 0을 만들면
      // 실제 값 0과 구분이 안 돼서 파싱 실패가 화면에 숨겨진다.
      final int? close = asInt(tds[1].text);
      // 전일비 셀은 텍스트에 "상승"/"하락" 접근성 문구가 섞여 있어 숫자 span만 골라 읽고,
      // 부호는 숫자에 없으니 <em> 클래스(bu_pdn=하락)로 판단해 따로 붙인다.
      final int? changeMagnitude = asInt(tds[2].querySelector('span.tah')?.text);
      final int? open = asInt(tds[3].text);
      final int? high = asInt(tds[4].text);
      final int? low = asInt(tds[5].text);
      final int? volume = asInt(tds[6].text);
      if (close == null ||
          changeMagnitude == null ||
          open == null ||
          high == null ||
          low == null ||
          volume == null) {
        continue;
      }
      final bool isDown = tds[2].querySelector('em.bu_pdn') != null;

      rows.add(
        DailyPriceRowDto(
          localDate: dateText.replaceAll('.', ''),
          closePrice: close,
          priceChange: isDown ? -changeMagnitude : changeMagnitude,
          openPrice: open,
          highPrice: high,
          lowPrice: low,
          accumulatedTradingVolume: volume,
        ),
      );
    }
    return rows;
  }

  static int _lastPageFrom(dom.Document document) {
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

  final Map<String, Map<int, DailyPricePage>> _cache = {};

  /// 캐시 히트면 네트워크 요청 없이 반환한다.
  Future<DailyPricePage> fetchPage(String code, int page) async {
    final cached = _cache[code]?[page];
    if (cached != null) return cached;

    final uri = Uri.parse(
      'https://finance.naver.com/item/sise_day.naver?code=$code&page=$page',
    );
    // 상태코드를 확인하지 않으면 차단/에러 응답을 "정상적인 빈 1페이지"로
    // 오해해서 캐시에 영구히 박아버릴 수 있다(naverGet이 200이 아니면 던짐).
    final response = await naverGet(_client, uri);
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
