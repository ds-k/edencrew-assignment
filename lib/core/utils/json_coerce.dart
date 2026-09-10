/// DTO `fromJson` 에서 쓰는 타입 강제 헬퍼.
///
/// Naver 응답은 같은 필드가 숫자로 오기도 하고 문자열(`"1,234"`)로 오기도 한다.
/// 파싱 실패 시 예외 대신 `null` 을 돌려주고, 값 해석은 상위 매핑 계층에 맡긴다.
library;

/// 숫자/숫자문자열 → `int`. 쉼표는 제거한다.
int? asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final String cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned) ?? double.tryParse(cleaned)?.toInt();
  }
  return null;
}

/// 숫자/숫자문자열 → `double`. 쉼표는 제거한다.
double? asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final String cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
  return null;
}

/// 임의 값 → 트림된 `String`. 빈 문자열은 `null`.
String? asString(Object? value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// 임의 값 → `bool`. `"true"` / `1` 도 참으로 본다.
bool? asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final String lower = value.trim().toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return null;
}
