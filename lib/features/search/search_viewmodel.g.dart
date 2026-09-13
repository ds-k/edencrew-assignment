// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultsHash() => r'f8381bf8f3dd873e488b880f9007fc80377e6a15';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
/// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
/// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
///
/// Copied from [searchResults].
@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily();

/// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
/// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
/// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
///
/// Copied from [searchResults].
class SearchResultsFamily extends Family<AsyncValue<List<SearchResult>>> {
  /// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
  /// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
  /// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
  ///
  /// Copied from [searchResults].
  const SearchResultsFamily();

  /// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
  /// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
  /// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
  ///
  /// Copied from [searchResults].
  SearchResultsProvider call(String query) {
    return SearchResultsProvider(query);
  }

  @override
  SearchResultsProvider getProviderOverride(
    covariant SearchResultsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultsProvider';
}

/// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
/// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
/// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
///
/// Copied from [searchResults].
class SearchResultsProvider
    extends AutoDisposeFutureProvider<List<SearchResult>> {
  /// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
  /// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
  /// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
  ///
  /// Copied from [searchResults].
  SearchResultsProvider(String query)
    : this._internal(
        (ref) => searchResults(ref as SearchResultsRef, query),
        from: searchResultsProvider,
        name: r'searchResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchResultsHash,
        dependencies: SearchResultsFamily._dependencies,
        allTransitiveDependencies:
            SearchResultsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<SearchResult>> Function(SearchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchResultsProvider._internal(
        (ref) => create(ref as SearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SearchResult>> createElement() {
    return _SearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchResultsRef on AutoDisposeFutureProviderRef<List<SearchResult>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<SearchResult>>
    with SearchResultsRef {
  _SearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as SearchResultsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
