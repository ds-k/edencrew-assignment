import 'dart:convert';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:http/http.dart' as http;

import '../dto/realtime_quote_dto.dart';

/// `GET https://polling.finance.naver.com/api/realtime`.
///
/// 응답은 `daily_price.html`과 마찬가지로 EUC-KR(CP949)이다 — `nm`(종목명) 필드 바이트가
/// 인코딩이 깨져서 오지만, 이 앱은 `nm`을 쓰지 않으므로 값 자체는 문제되지 않는다. 다만
/// UTF-8로 그대로 디코딩하면 JSON 파싱 전에 예외가 나므로 `cp949.decode`를 거쳐야 한다.
class NaverQuoteApi {
  NaverQuoteApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// 관심종목 전부를 한 번의 요청으로 조회한다. `symbols`가 비어 있으면 요청을 보내지 않는다.
  Future<List<RealtimeQuoteDto>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return const <RealtimeQuoteDto>[];

    final uri = Uri.https('polling.finance.naver.com', '/api/realtime', {
      'query': 'SERVICE_ITEM:${symbols.join(',')}',
    });
    final response = await _client.get(uri);
    final json =
        jsonDecode(cp949.decode(response.bodyBytes)) as Map<String, dynamic>;
    return RealtimeQuoteDto.listFromResponse(json);
  }
}
