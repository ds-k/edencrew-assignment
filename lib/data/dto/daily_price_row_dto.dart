import 'package:flutter/foundation.dart';

/// `finance.naver.com/item/sise_day.naver` HTML의 데이터 행 한 줄.
///
/// 필드명은 `docs/NAVER_API.md` "4. 일별 시세 HTML"이 "파싱해서 추출해야 하는 값"으로
/// 명시한 이름(`localDate`/`closePrice`/`openPrice`/`highPrice`/`lowPrice`/
/// `accumulatedTradingVolume`/`lastPage`)을 그대로 따른다. HTML은 JSON과 달리 원본
/// 필드명이 없어서, 이 문서에 적힌 이름이 곧 이 endpoint의 "원형" 계약이라고 본다.
///
/// 표 컬럼 순서는 `종가, 전일비, 시가, 고가, 저가, 거래량` — 전일비는 등락 계산에
/// 쓰지 않으므로(가격/등락은 실시간 시세 dto에서 계산) 담지 않는다.
@immutable
class DailyPriceRowDto {
  const DailyPriceRowDto({
    required this.localDate,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
  });

  /// `yyyyMMdd`. 원본은 `2026.09.10` 형태라 `.`을 제거해 정규화한다.
  final String localDate;

  final int closePrice;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int accumulatedTradingVolume;
}

/// 일별 시세 한 페이지(10거래일) + 전체 페이지 수.
@immutable
class DailyPricePage {
  const DailyPricePage({required this.rows, required this.lastPage});

  final List<DailyPriceRowDto> rows;

  /// 페이지 네비게이션의 "맨뒤" 링크에서 얻은 마지막 페이지 번호.
  final int lastPage;
}
