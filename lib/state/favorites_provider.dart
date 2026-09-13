import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'preferences_provider.dart';

part 'favorites_provider.g.dart';

const String _prefsKey = 'favorites';

/// 관심 상태의 단일 진실 소스. 관심/검색/상세 세 화면이 이 provider 하나만 watch한다.
///
/// 값은 [Stock.id]/[SearchResult.id] 형식(`domestic:{symbol}`)의 종목 id 집합.
/// 변경할 때마다 `shared_preferences`에 즉시 저장해 앱을 재실행해도 유지된다.
@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  @override
  Set<String> build() {
    final List<String>? saved = ref.watch(sharedPreferencesProvider).getStringList(_prefsKey);
    return saved?.toSet() ?? const <String>{};
  }

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
    _persist();
  }

  void remove(String id) {
    if (!state.contains(id)) return;
    state = {...state}..remove(id);
    _persist();
  }

  void _persist() {
    ref.read(sharedPreferencesProvider).setStringList(_prefsKey, state.toList()).ignore();
  }
}
