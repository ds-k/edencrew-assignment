import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/network/naver_http_client.dart';
import '../dto/stock_metadata_dto.dart';

/// `GET https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/{symbol}`.
/// UTF-8 JSON. 종목명/거래소명은 세션 중 사실상 불변이라 심볼별로 캐시한다.
class NaverMetadataApi {
  NaverMetadataApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  final Map<String, StockMetadataDto> _cache = {};

  Future<StockMetadataDto> fetchMetadata(String symbol) async {
    final cached = _cache[symbol];
    if (cached != null) return cached;

    final uri = Uri.parse(
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/$symbol',
    );
    final response = await naverGet(_client, uri);
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final dto = StockMetadataDto.fromJson(json);

    _cache[symbol] = dto;
    return dto;
  }

  void clearCache() => _cache.clear();
}
