import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/preferences_provider.dart';

part 'recent_searches_provider.g.dart';

const String _prefsKey = 'recent_searches';
const int _maxEntries = 10;

/// 최근 검색어. 디바운스를 통과해 실제로 실행된 검색만 기록한다(타이핑 중간값 제외).
/// 최신순, 중복 없음, 최대 [_maxEntries]개. `shared_preferences`에 즉시 저장한다.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  @override
  List<String> build() {
    return ref.watch(sharedPreferencesProvider).getStringList(_prefsKey) ??
        const <String>[];
  }

  void add(String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final List<String> updated = [
      trimmed,
      ...state.where((String q) => q != trimmed),
    ].take(_maxEntries).toList();

    state = updated;
    ref.read(sharedPreferencesProvider).setStringList(_prefsKey, updated).ignore();
  }

  void clear() {
    state = const <String>[];
    ref.read(sharedPreferencesProvider).remove(_prefsKey).ignore();
  }
}
