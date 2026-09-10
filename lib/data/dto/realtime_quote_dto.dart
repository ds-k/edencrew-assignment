import 'package:flutter/foundation.dart';

import '../../core/utils/json_coerce.dart';

/// `GET https://polling.finance.naver.com/api/realtime` 응답의 시세 한 건.
///
/// 응답 구조는 `result.areas[].datas[]` 로 중첩되어 있고, 관심종목 여러 개를
/// 한 번의 요청으로 받는다. [listFromResponse] 로 datas 배열을 평탄화한다.
///
/// 등락액/등락률/시가총액은 이 DTO 에서 계산하지 않는다. 원본 필드만 담고
/// 계산은 repository 매핑에서 한다. (`nv - pcv`, `(nv - pcv) / pcv`,
/// `nv * countOfListedStock`)
///
/// 이 endpoint 응답의 charset 은 EUC-KR 이다. `nm`(종목명)은 인코딩이 깨져
/// 오므로 담지 않는다. 종목명은 메타데이터 endpoint 를 쓴다.
@immutable
class RealtimeQuoteDto {
  const RealtimeQuoteDto({
    required this.symbol,
    this.currentPrice,
    this.previousClose,
    this.open,
    this.high,
    this.low,
    this.accumulatedVolume,
    this.listedShareCount,
  });

  factory RealtimeQuoteDto.fromJson(Map<String, dynamic> json) {
    return RealtimeQuoteDto(
      symbol: asString(json['cd']) ?? '',
      currentPrice: asInt(json['nv']),
      previousClose: asInt(json['pcv']),
      open: asInt(json['ov']),
      high: asInt(json['hv']),
      low: asInt(json['lv']),
      accumulatedVolume: asInt(json['aq']),
      listedShareCount: asInt(json['countOfListedStock']),
    );
  }

  /// 응답 전체(`{ "result": { "areas": [...] } }`)에서 시세 목록을 뽑는다.
  static List<RealtimeQuoteDto> listFromResponse(Map<String, dynamic> json) {
    final Object? result = json['result'];
    if (result is! Map<String, dynamic>) return const <RealtimeQuoteDto>[];
    final Object? areas = result['areas'];
    if (areas is! List) return const <RealtimeQuoteDto>[];

    return <RealtimeQuoteDto>[
      for (final Object? area in areas)
        if (area is Map<String, dynamic> && area['datas'] is List)
          for (final Object? data in area['datas'] as List)
            if (data is Map<String, dynamic>) RealtimeQuoteDto.fromJson(data),
    ];
  }

  /// `cd`. 6자리 종목코드.
  final String symbol;

  /// `nv`. 현재가.
  final int? currentPrice;

  /// `pcv`. 전일 종가.
  final int? previousClose;

  /// `ov` / `hv` / `lv`. 당일 시가 / 고가 / 저가.
  final int? open;
  final int? high;
  final int? low;

  /// `aq`. 누적 거래량.
  final int? accumulatedVolume;

  /// `countOfListedStock`. 상장 주식 수. 시가총액 계산에 쓴다.
  final int? listedShareCount;
}
