import 'package:flutter/foundation.dart';

/// `finance.naver.com/item/sise_day.naver` HTML의 데이터 행 한 줄.
///
/// 필드명은 `docs/NAVER_API.md` "4. 일별 시세 HTML"이 "파싱해서 추출해야 하는 값"으로
/// 명시한 이름(`localDate`/`closePrice`/`openPrice`/`highPrice`/`lowPrice`/
/// `accumulatedTradingVolume`/`lastPage`)을 그대로 따른다. HTML은 JSON과 달리 원본
/// 필드명이 없어서, 이 문서에 적힌 이름이 곧 이 endpoint의 "원형" 계약이라고 본다.
///
/// 표 컬럼 순서는 `종가, 전일비, 시가, 고가, 저가, 거래량`.
///
/// 전일비 셀은 숫자에 부호가 없고(`<em class="bu_pup/bu_pdn/bu_pn">` 클래스로만
/// 상승/하락/보합을 구분) 텍스트에 "상승"/"하락" 같은 접근성 문구가 섞여 있어, 다른
/// 숫자 컬럼처럼 셀 전체 텍스트를 그대로 파싱할 수 없다. `naver_daily_price_api.dart`가
/// 숫자 span과 `<em>` 클래스를 따로 읽어 부호를 붙인 뒤 [priceChange]에 담는다.
@immutable
class DailyPriceRowDto {
  const DailyPriceRowDto({
    required this.localDate,
    required this.closePrice,
    required this.priceChange,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
  });

  /// `yyyyMMdd`. 원본은 `2026.09.10` 형태라 `.`을 제거해 정규화한다.
  final String localDate;

  final int closePrice;

  /// 전일 대비 등락액. 하락이면 음수, 보합이면 0.
  final int priceChange;

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
