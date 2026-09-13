import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/preferences_provider.dart';
import '../../data/models/stock.dart';

part 'sort_order.g.dart';

const String _prefsKey = 'sort_order';

enum SortOrder {
  price('현재가순'),
  changeRate('등락률순'),
  alphabetical('가나다순');

  const SortOrder(this.label);

  final String label;
}

/// 선택된 정렬 기준. 앱을 재실행해도 유지되도록 `shared_preferences`에 저장한다.
@riverpod
class SelectedSortOrder extends _$SelectedSortOrder {
  @override
  SortOrder build() {
    final String? saved = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    return SortOrder.values.firstWhere(
      (SortOrder order) => order.name == saved,
      orElse: () => SortOrder.alphabetical,
    );
  }

  void select(SortOrder order) {
    state = order;
    ref.read(sharedPreferencesProvider).setString(_prefsKey, order.name).ignore();
  }
}

/// 시세 미수신 종목(`hasQuote == false`)은 `price`/`changeRate` 정렬에서 항상 맨 뒤로 보낸다.
/// `alphabetical`은 이름만 비교하므로 시세 수신 여부와 무관하게 섞여 들어간다.
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
