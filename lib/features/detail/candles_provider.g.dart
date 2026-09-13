// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$candlesHash() => r'7e1a96080b5cd5b221a5ce5526ddce611c86bc88';

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

/// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
///
/// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
/// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
/// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
///
/// Copied from [candles].
@ProviderFor(candles)
const candlesProvider = CandlesFamily();

/// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
///
/// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
/// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
/// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
///
/// Copied from [candles].
class CandlesFamily extends Family<AsyncValue<List<Candle>>> {
  /// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
  ///
  /// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
  /// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
  /// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
  ///
  /// Copied from [candles].
  const CandlesFamily();

  /// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
  ///
  /// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
  /// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
  /// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
  ///
  /// Copied from [candles].
  CandlesProvider call(String symbol, ChartPeriod period) {
    return CandlesProvider(symbol, period);
  }

  @override
  CandlesProvider getProviderOverride(covariant CandlesProvider provider) {
    return call(provider.symbol, provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'candlesProvider';
}

/// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
///
/// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
/// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
/// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
///
/// Copied from [candles].
class CandlesProvider extends AutoDisposeFutureProvider<List<Candle>> {
  /// 일별 시세 표/차트용 캔들. 심볼+기간 조합별로 요청한다.
  ///
  /// 이 provider 자체는 탭을 벗어나면 autoDispose로 사라지지만, 실제 페이지 캐시는
  /// `NaverDailyPriceApi`(심볼+페이지 단위, 앱 세션 내내 유지)에 있어서 기간 탭을
  /// 다시 눌러도 이미 받은 페이지는 재요청하지 않는다.
  ///
  /// Copied from [candles].
  CandlesProvider(String symbol, ChartPeriod period)
    : this._internal(
        (ref) => candles(ref as CandlesRef, symbol, period),
        from: candlesProvider,
        name: r'candlesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$candlesHash,
        dependencies: CandlesFamily._dependencies,
        allTransitiveDependencies: CandlesFamily._allTransitiveDependencies,
        symbol: symbol,
        period: period,
      );

  CandlesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.period,
  }) : super.internal();

  final String symbol;
  final ChartPeriod period;

  @override
  Override overrideWith(
    FutureOr<List<Candle>> Function(CandlesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CandlesProvider._internal(
        (ref) => create(ref as CandlesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Candle>> createElement() {
    return _CandlesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CandlesProvider &&
        other.symbol == symbol &&
        other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CandlesRef on AutoDisposeFutureProviderRef<List<Candle>> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `period` of this provider.
  ChartPeriod get period;
}

class _CandlesProviderElement
    extends AutoDisposeFutureProviderElement<List<Candle>>
    with CandlesRef {
  _CandlesProviderElement(super.provider);

  @override
  String get symbol => (origin as CandlesProvider).symbol;
  @override
  ChartPeriod get period => (origin as CandlesProvider).period;
}

String _$selectedPeriodHash() => r'3ad345fc46d710e508fd27216f3cde8523a58ca9';

/// 상세 화면에서 선택된 기간 탭. 화면이 하나만 떠 있고 autoDispose 기본값이라
/// 심볼별로 나눌 필요 없이(다음 상세 화면은 새로 `month1`부터 시작) 이 하나로 충분하다.
///
/// Copied from [SelectedPeriod].
@ProviderFor(SelectedPeriod)
final selectedPeriodProvider =
    AutoDisposeNotifierProvider<SelectedPeriod, ChartPeriod>.internal(
      SelectedPeriod.new,
      name: r'selectedPeriodProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedPeriodHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPeriod = AutoDisposeNotifier<ChartPeriod>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
