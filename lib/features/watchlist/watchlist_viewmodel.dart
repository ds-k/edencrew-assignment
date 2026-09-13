import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/stock.dart';
import '../../state/favorites_provider.dart';
import '../../state/quote_cache_provider.dart';

part 'watchlist_viewmodel.g.dart';

@riverpod
class WatchlistViewModel extends _$WatchlistViewModel {
  @override
  Future<List<Stock>> build() async {
    final Set<String> ids = ref.watch(favoritesProvider);
    if (ids.isEmpty) return const <Stock>[];

    final List<String> symbols = [for (final String id in ids) id.split(':').last];
    return ref.read(quoteCacheProvider.notifier).refresh(symbols);
  }

  /// 상단 새로고침 버튼. 시세를 다시 조회하고 완료될 때까지 기다린다.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
