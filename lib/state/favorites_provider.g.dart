// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesHash() => r'2df623df2330e60778a30f24fd28706596b13a07';

/// 관심 상태의 단일 진실 소스. 관심/검색/상세 세 화면이 이 provider 하나만 watch한다.
///
/// 값은 [Stock.id]/[SearchResult.id] 형식(`domestic:{symbol}`)의 종목 id 집합.
///
/// Copied from [Favorites].
@ProviderFor(Favorites)
final favoritesProvider =
    AutoDisposeNotifierProvider<Favorites, Set<String>>.internal(
      Favorites.new,
      name: r'favoritesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoritesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Favorites = AutoDisposeNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
