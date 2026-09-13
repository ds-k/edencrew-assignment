/// 일별 시세 표의 날짜 표기. 예: `2026-09-10` → `09.10`.
String formatMonthDay(DateTime date) {
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${pad(date.month)}.${pad(date.day)}';
}
