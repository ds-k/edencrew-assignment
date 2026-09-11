import 'package:flutter/foundation.dart';

import '../dto/daily_price_row_dto.dart';

/// 상세 화면 기간 탭. `pageCount`는 `NaverDailyPriceApi.fetchRange`에 그대로 넘긴다.
///
/// 향후 캔들 차트에 쓸 `candlesticks` 패키지도 모델 클래스명이 `Candle`이라, 상세 화면에서
/// 같이 쓸 때는 `import 'package:candlesticks/candlesticks.dart' as cs;`처럼 alias가 필요하다.
enum ChartPeriod {
  month1(pageCount: 2, label: '1개월'),
  month3(pageCount: 6, label: '3개월'),
  month6(pageCount: 12, label: '6개월'),
  year1(pageCount: 25, label: '1년');

  const ChartPeriod({required this.pageCount, required this.label});

  final int pageCount;
  final String label;
}

/// 캔들 하나. `DailyPriceRowDto` 기반.
///
/// 가격/거래량은 원화·주식 수량이라 정수로 담는다(`candlesticks` 패키지의 `Candle`은
/// `double`을 쓰므로, 위젯에 넘길 때 그쪽에서 `.toDouble()` 변환).
@immutable
class Candle {
  const Candle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromDto(DailyPriceRowDto dto) {
    final String localDate = dto.localDate;
    return Candle(
      date: DateTime(
        int.parse(localDate.substring(0, 4)),
        int.parse(localDate.substring(4, 6)),
        int.parse(localDate.substring(6, 8)),
      ),
      open: dto.openPrice,
      high: dto.highPrice,
      low: dto.lowPrice,
      close: dto.closePrice,
      volume: dto.accumulatedTradingVolume,
    );
  }

  final DateTime date;
  final int open;
  final int high;
  final int low;
  final int close;
  final int volume;

  bool get isUp => close >= open;
}
