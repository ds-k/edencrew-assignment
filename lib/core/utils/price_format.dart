/// 천단위 콤마 표기. 예: `179700` → `179,700`, `-400` → `-400`.
String formatPrice(int value) {
  final bool negative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-${buffer.toString()}' : buffer.toString();
}

/// 등락액 + 등락률 표기. 예: `-400 (-0.22%)`, `+9,500 (+2.36%)`, `0 (0.00%)`.
String formatPriceChange(int change, double rate) {
  final String changeSign = change > 0 ? '+' : '';
  final String rateSign = rate > 0 ? '+' : '';
  final String rateStr = (rate * 100).toStringAsFixed(2);
  return '$changeSign${formatPrice(change)} ($rateSign$rateStr%)';
}

/// 등락률 없이 부호만 붙인 등락액. 예: `-400`, `+1,200`, `0`. 일별 시세 표에서 쓴다.
String formatSignedPrice(int change) {
  if (change > 0) return '+${formatPrice(change)}';
  return formatPrice(change);
}
