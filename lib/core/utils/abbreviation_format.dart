import 'price_format.dart';

/// 거래량 축약 표기. 항상 천 단위로 접는다(국내 증권 앱 관행).
/// 예: `29113000` → `29,113천`.
String formatVolume(int volume) => '${formatPrice(volume ~/ 1000)}천';

/// 시가총액 축약 표기. 조(10^12)/억(10^8)/만(10^4) 중 값에 맞는 가장 큰 단위 하나를 골라 접는다.
/// 예: `1063000000000000` → `1,063조`. 1만 미만이면 콤마만 적용한다.
String formatMarketCap(int marketCap) {
  if (marketCap >= 1000000000000) {
    return '${formatPrice(marketCap ~/ 1000000000000)}조';
  }
  if (marketCap >= 100000000) return '${formatPrice(marketCap ~/ 100000000)}억';
  if (marketCap >= 10000) return '${formatPrice(marketCap ~/ 10000)}만';
  return formatPrice(marketCap);
}
