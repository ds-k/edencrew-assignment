import 'package:flutter/foundation.dart';

/// 검색 화면이 쓰는 검색 결과 한 건. `SearchSuggestionDto`(자동완성 응답) 기반.
///
/// 메타데이터 endpoint는 여기서 쓰지 않는다 — 자동완성 응답에 이미 `name`/`typeName`이
/// 있어서, 검색 결과 한 건마다 메타데이터를 또 부르면 N+1이 된다.
@immutable
class SearchResult {
  const SearchResult({
    required this.id,
    required this.symbol,
    required this.name,
    required this.market,
  });

  /// `domestic:{symbol}`. 관심 등록 등에서 쓰는 canonical id.
  final String id;

  /// 6자리 종목코드.
  final String symbol;

  final String name;

  /// `typeName`. 예: `코스피`.
  final String market;
}
