// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyCandlesHash() => r'3765dca1a3e105136d2234992a93ceb57d1310c5';

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

/// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
///
/// Copied from [monthlyCandles].
@ProviderFor(monthlyCandles)
const monthlyCandlesProvider = MonthlyCandlesFamily();

/// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
///
/// Copied from [monthlyCandles].
class MonthlyCandlesFamily extends Family<AsyncValue<List<Candle>>> {
  /// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
  ///
  /// Copied from [monthlyCandles].
  const MonthlyCandlesFamily();

  /// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
  ///
  /// Copied from [monthlyCandles].
  MonthlyCandlesProvider call(String symbol) {
    return MonthlyCandlesProvider(symbol);
  }

  @override
  MonthlyCandlesProvider getProviderOverride(
    covariant MonthlyCandlesProvider provider,
  ) {
    return call(provider.symbol);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyCandlesProvider';
}

/// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
///
/// Copied from [monthlyCandles].
class MonthlyCandlesProvider extends AutoDisposeFutureProvider<List<Candle>> {
  /// 일별 시세 표/차트용 캔들. 기간 탭 연동 전까지는 1개월 고정으로 조회한다.
  ///
  /// Copied from [monthlyCandles].
  MonthlyCandlesProvider(String symbol)
    : this._internal(
        (ref) => monthlyCandles(ref as MonthlyCandlesRef, symbol),
        from: monthlyCandlesProvider,
        name: r'monthlyCandlesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlyCandlesHash,
        dependencies: MonthlyCandlesFamily._dependencies,
        allTransitiveDependencies:
            MonthlyCandlesFamily._allTransitiveDependencies,
        symbol: symbol,
      );

  MonthlyCandlesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
  }) : super.internal();

  final String symbol;

  @override
  Override overrideWith(
    FutureOr<List<Candle>> Function(MonthlyCandlesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyCandlesProvider._internal(
        (ref) => create(ref as MonthlyCandlesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Candle>> createElement() {
    return _MonthlyCandlesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyCandlesProvider && other.symbol == symbol;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyCandlesRef on AutoDisposeFutureProviderRef<List<Candle>> {
  /// The parameter `symbol` of this provider.
  String get symbol;
}

class _MonthlyCandlesProviderElement
    extends AutoDisposeFutureProviderElement<List<Candle>>
    with MonthlyCandlesRef {
  _MonthlyCandlesProviderElement(super.provider);

  @override
  String get symbol => (origin as MonthlyCandlesProvider).symbol;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
