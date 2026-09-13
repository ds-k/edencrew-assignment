import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/stock.dart';
import '../../state/quote_cache_provider.dart';

part 'detail_viewmodel.g.dart';

@riverpod
class DetailViewModel extends _$DetailViewModel {
  @override
  Future<Stock> build(String symbol) async {
    final List<Stock> stocks = await ref
        .read(quoteCacheProvider.notifier)
        .refresh(<String>[symbol]);
    return stocks.first;
  }
}
