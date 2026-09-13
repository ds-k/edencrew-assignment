import 'package:flutter/widgets.dart';

/// [text]에서 [query]와 일치하는 모든 구간에 [highlight] 스타일을, 나머지에 [normal] 스타일을 적용한다.
/// 대소문자를 구분하지 않는다. [query]가 비어 있으면 전체를 [normal]로 반환한다.
List<InlineSpan> highlightedSpans(
  String text,
  String query, {
  required TextStyle normal,
  required TextStyle highlight,
}) {
  if (query.isEmpty) return <InlineSpan>[TextSpan(text: text, style: normal)];

  final String lowerText = text.toLowerCase();
  final String lowerQuery = query.toLowerCase();
  final List<InlineSpan> spans = <InlineSpan>[];
  int start = 0;

  while (true) {
    final int index = lowerText.indexOf(lowerQuery, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start), style: normal));
      break;
    }
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index), style: normal));
    }
    spans.add(
      TextSpan(text: text.substring(index, index + query.length), style: highlight),
    );
    start = index + query.length;
  }

  return spans;
}
