import 'package:flutter/foundation.dart';

import 'json_coerce.dart';

/// `GET https://ac.stock.naver.com/ac` 응답 전체.
///
/// `{ "query": "...", "items": [ ... ] }` 형태. 국내 주식 필터링과
/// canonical id(`domestic:{symbol}`) 생성은 여기서 하지 않고 repository 에서 한다.
@immutable
class SearchAutocompleteDto {
  const SearchAutocompleteDto({required this.query, required this.items});

  factory SearchAutocompleteDto.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<SearchSuggestionDto> items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(SearchSuggestionDto.fromJson)
            .toList(growable: false)
        : const <SearchSuggestionDto>[];
    return SearchAutocompleteDto(
      query: asString(json['query']) ?? '',
      items: items,
    );
  }

  final String query;
  final List<SearchSuggestionDto> items;
}

/// 자동완성 결과 한 건. 응답 필드를 가공 없이 그대로 담는다.
@immutable
class SearchSuggestionDto {
  const SearchSuggestionDto({
    this.code,
    this.name,
    this.typeCode,
    this.typeName,
    this.url,
    this.reutersCode,
    this.nationCode,
    this.nationName,
    this.category,
  });

  factory SearchSuggestionDto.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionDto(
      code: asString(json['code']),
      name: asString(json['name']),
      typeCode: asString(json['typeCode']),
      typeName: asString(json['typeName']),
      url: asString(json['url']),
      reutersCode: asString(json['reutersCode']),
      nationCode: asString(json['nationCode']),
      nationName: asString(json['nationName']),
      category: asString(json['category']),
    );
  }

  /// 종목코드. 국내 주식이면 6자리 숫자, 해외/지수는 티커나 코드.
  final String? code;
  final String? name;

  /// `KOSPI`, `KOSDAQ`, `NASDAQ`, `INDEX` 등.
  final String? typeCode;

  /// `코스피`, `코스닥`, `나스닥 증권거래소` 등.
  final String? typeName;
  final String? url;
  final String? reutersCode;

  /// `KOR`, `USA`, `JPN` … 지수는 보통 `null`.
  final String? nationCode;
  final String? nationName;

  /// `stock`, `index`, `ipo`, `marketindicator`.
  final String? category;
}
