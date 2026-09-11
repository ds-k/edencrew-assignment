import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dto/search_suggestion_dto.dart';

/// `GET https://ac.stock.naver.com/ac`. 응답은 UTF-8 JSON.
class NaverSearchApi {
  NaverSearchApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SearchAutocompleteDto> autocomplete(String query) async {
    // `Uri.https`로 만들어야 한글 검색어가 올바르게 percent-encoding 된다.
    final uri = Uri.https('ac.stock.naver.com', '/ac', {
      'q': query,
      'target': 'stock,ipo,index,marketindicator',
    });
    final response = await _client.get(uri);
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return SearchAutocompleteDto.fromJson(json);
  }
}
