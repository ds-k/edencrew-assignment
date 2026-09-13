import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_provider.g.dart';

/// 관심 상태의 단일 진실 소스. 관심/검색/상세 세 화면이 이 provider 하나만 watch한다.
///
/// 값은 [Stock.id]/[SearchResult.id] 형식(`domestic:{symbol}`)의 종목 id 집합.
@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  @override
  Set<String> build() => const <String>{};

  bool isFavorite(String id) => state.contains(id);

  void toggle(String id) {
    if (state.contains(id)) {
      remove(id);
    } else {
      add(id);
    }
  }

  void add(String id) {
    if (state.contains(id)) return;
    state = {...state, id};
  }

  void remove(String id) {
    if (!state.contains(id)) return;
    state = {...state}..remove(id);
  }
}
