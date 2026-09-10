import 'package:flutter/foundation.dart';

import '../../core/utils/json_coerce.dart';

/// `GET https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/{symbol}`
/// 응답. 플랫한 객체 하나다.
///
/// 화면에서 `005930 · 코스피` 로 보이는 부분이 [symbolCode] + [exchangeNameKor].
@immutable
class StockMetadataDto {
  const StockMetadataDto({
    this.symbolCode,
    this.stockName,
    this.exchangeName,
    this.exchangeNameKor,
    this.nationType,
    this.isDelisting,
  });

  factory StockMetadataDto.fromJson(Map<String, dynamic> json) {
    return StockMetadataDto(
      symbolCode: asString(json['symbolCode']) ?? asString(json['itemCode']),
      stockName: asString(json['stockName']),
      exchangeName: asString(json['stockExchangeName']),
      exchangeNameKor: asString(json['stockExchangeNameKor']),
      nationType: asString(json['nationType']),
      isDelisting: asBool(json['isDelisting']),
    );
  }

  /// `symbolCode`. 6자리 종목코드.
  final String? symbolCode;

  /// `stockName`. 종목명.
  final String? stockName;

  /// `stockExchangeName`. `KOSPI` / `KOSDAQ`.
  final String? exchangeName;

  /// `stockExchangeNameKor`. `코스피` / `코스닥`.
  final String? exchangeNameKor;

  /// `nationType`. `KOR` 등.
  final String? nationType;

  /// `isDelisting`. 상장폐지 여부.
  final bool? isDelisting;
}
