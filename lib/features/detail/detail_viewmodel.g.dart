// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detailViewModelHash() => r'd879427a1e2dc4bb6b2988e2aed9ebe6e1b80d55';

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

abstract class _$DetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<Stock> {
  late final String symbol;

  FutureOr<Stock> build(String symbol);
}

/// See also [DetailViewModel].
@ProviderFor(DetailViewModel)
const detailViewModelProvider = DetailViewModelFamily();

/// See also [DetailViewModel].
class DetailViewModelFamily extends Family<AsyncValue<Stock>> {
  /// See also [DetailViewModel].
  const DetailViewModelFamily();

  /// See also [DetailViewModel].
  DetailViewModelProvider call(String symbol) {
    return DetailViewModelProvider(symbol);
  }

  @override
  DetailViewModelProvider getProviderOverride(
    covariant DetailViewModelProvider provider,
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
  String? get name => r'detailViewModelProvider';
}

/// See also [DetailViewModel].
class DetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DetailViewModel, Stock> {
  /// See also [DetailViewModel].
  DetailViewModelProvider(String symbol)
    : this._internal(
        () => DetailViewModel()..symbol = symbol,
        from: detailViewModelProvider,
        name: r'detailViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$detailViewModelHash,
        dependencies: DetailViewModelFamily._dependencies,
        allTransitiveDependencies:
            DetailViewModelFamily._allTransitiveDependencies,
        symbol: symbol,
      );

  DetailViewModelProvider._internal(
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
  FutureOr<Stock> runNotifierBuild(covariant DetailViewModel notifier) {
    return notifier.build(symbol);
  }

  @override
  Override overrideWith(DetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: DetailViewModelProvider._internal(
        () => create()..symbol = symbol,
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
  AutoDisposeAsyncNotifierProviderElement<DetailViewModel, Stock>
  createElement() {
    return _DetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailViewModelProvider && other.symbol == symbol;
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
mixin DetailViewModelRef on AutoDisposeAsyncNotifierProviderRef<Stock> {
  /// The parameter `symbol` of this provider.
  String get symbol;
}

class _DetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DetailViewModel, Stock>
    with DetailViewModelRef {
  _DetailViewModelProviderElement(super.provider);

  @override
  String get symbol => (origin as DetailViewModelProvider).symbol;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
