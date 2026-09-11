import 'package:flutter/foundation.dart';

/// 등락 방향. 상승/하락 색 매핑은 화면(테마 토큰)의 몫이라 여기서는 방향만 나타낸다.
enum PriceDirection { up, down, flat }

/// 관심/검색/상세 화면이 공통으로 쓰는 종목 모델.
/// `StockMetadataDto`(이름/시장) + `RealtimeQuoteDto`(시세) 조합.
///
/// 시세 필드는 전부 nullable — 실시간 시세 응답에 해당 심볼이 없으면([hasQuote]가 `false`)
/// 이름/시장만 채워진 채로 표시한다(시세 미수신 상태).
@immutable
class Stock {
  const Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.market,
    this.price,
    this.priceChange,
    this.changeRate,
    this.open,
    this.high,
    this.low,
    this.volume,
    this.marketCap,
  });

  /// `domestic:{symbol}`.
  final String id;
  final String symbol;
  final String name;

  /// `stockExchangeNameKor`. 예: `코스피`.
  final String market;

  /// `nv`. 현재가.
  final int? price;

  /// `nv - pcv`.
  final int? priceChange;

  /// `(nv - pcv) / pcv`.
  final double? changeRate;

  final int? open;
  final int? high;
  final int? low;

  /// `aq`. 누적 거래량.
  final int? volume;

  /// `nv * countOfListedStock`.
  final int? marketCap;

  /// 실시간 시세를 받았는지. `false`면 이름/시장만 있고 나머지는 전부 `null`.
  bool get hasQuote => price != null;

  PriceDirection get direction {
    final int? change = priceChange;
    if (change == null || change == 0) return PriceDirection.flat;
    return change > 0 ? PriceDirection.up : PriceDirection.down;
  }
}
