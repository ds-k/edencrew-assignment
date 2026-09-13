import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/stock.dart';

part 'sort_order.g.dart';

enum SortOrder {
  price('현재가순'),
  changeRate('등락률순'),
  alphabetical('가나다순');

  const SortOrder(this.label);

  final String label;
}

@riverpod
class SelectedSortOrder extends _$SelectedSortOrder {
  @override
  SortOrder build() => SortOrder.alphabetical;

  void select(SortOrder order) => state = order;
}

/// 시세 미수신 종목(`hasQuote == false`)은 정렬 기준과 무관하게 항상 맨 뒤로 보낸다.
List<Stock> sortStocks(List<Stock> stocks, SortOrder order) {
  final List<Stock> sorted = List<Stock>.of(stocks);
  switch (order) {
    case SortOrder.alphabetical:
      sorted.sort((Stock a, Stock b) => a.name.compareTo(b.name));
    case SortOrder.price:
      sorted.sort(_byNullableDesc((Stock s) => s.price));
    case SortOrder.changeRate:
      sorted.sort(_byNullableDesc((Stock s) => s.changeRate));
  }
  return sorted;
}

int Function(Stock, Stock) _byNullableDesc(num? Function(Stock) key) {
  return (Stock a, Stock b) {
    final num? valueA = key(a);
    final num? valueB = key(b);
    if (valueA == null && valueB == null) return 0;
    if (valueA == null) return 1;
    if (valueB == null) return -1;
    return valueB.compareTo(valueA);
  };
}
