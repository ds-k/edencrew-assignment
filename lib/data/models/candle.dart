import 'package:flutter/foundation.dart';

import '../dto/daily_price_row_dto.dart';

/// 상세 화면 기간 탭. `pageCount`는 `NaverDailyPriceApi.fetchRange`에 그대로 넘긴다.
enum ChartPeriod {
  month1(pageCount: 2, label: '1개월'),
  month3(pageCount: 6, label: '3개월'),
  month6(pageCount: 12, label: '6개월'),
  year1(pageCount: 25, label: '1년');

  const ChartPeriod({required this.pageCount, required this.label});

  final int pageCount;
  final String label;
}

/// 캔들 하나. `DailyPriceRowDto` 기반. 가격/거래량은 원화·주식 수량이라 정수로 담는다.
@immutable
class Candle {
  const Candle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.priceChange,
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
      priceChange: dto.priceChange,
      volume: dto.accumulatedTradingVolume,
    );
  }

  final DateTime date;
  final int open;
  final int high;
  final int low;
  final int close;

  /// 전일 대비 등락액(일별 시세 표의 "등락" 컬럼). 하락이면 음수, 보합이면 0.
  final int priceChange;

  final int volume;

  bool get isUp => close >= open;
}
