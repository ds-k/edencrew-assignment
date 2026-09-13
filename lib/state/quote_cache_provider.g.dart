// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quoteCacheHash() => r'ede05bed8c408defc72122ca66e96d3cc8103c7c';

/// 종목코드별 시세 캐시. 관심/상세 화면이 같은 심볼을 동시에 요청해도
/// 진행 중인 배치 조회가 있으면 그 결과를 공유해 API를 중복 호출하지 않는다.
///
/// Copied from [QuoteCache].
@ProviderFor(QuoteCache)
final quoteCacheProvider =
    NotifierProvider<QuoteCache, Map<String, Stock>>.internal(
      QuoteCache.new,
      name: r'quoteCacheProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quoteCacheHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$QuoteCache = Notifier<Map<String, Stock>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
