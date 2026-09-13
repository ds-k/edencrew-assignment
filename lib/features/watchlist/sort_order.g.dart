// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_order.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedSortOrderHash() => r'884fd581854cfde9d963c832a6b85b2b3e97868b';

/// 선택된 정렬 기준. 앱을 재실행해도 유지되도록 `shared_preferences`에 저장한다.
///
/// Copied from [SelectedSortOrder].
@ProviderFor(SelectedSortOrder)
final selectedSortOrderProvider =
    AutoDisposeNotifierProvider<SelectedSortOrder, SortOrder>.internal(
      SelectedSortOrder.new,
      name: r'selectedSortOrderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedSortOrderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedSortOrder = AutoDisposeNotifier<SortOrder>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
