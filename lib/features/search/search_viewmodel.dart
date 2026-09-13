import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/search_result.dart';
import '../../data/repositories/naver_stock_repository.dart';

part 'search_viewmodel.g.dart';

/// 검색어별 결과. 타이핑 중 계속 바뀌는 [query]를 family 파라미터로 받아 매번 새 인스턴스가
/// 생기므로(autoDispose 기본), 300ms 안에 다음 타이핑이 오면 이전 인스턴스가 dispose되어
/// 대부분의 중간 요청이 실제 네트워크까지 가지 않는다.
@riverpod
Future<List<SearchResult>> searchResults(SearchResultsRef ref, String query) async {
  final String trimmed = query.trim();
  if (trimmed.isEmpty) return const <SearchResult>[];

  bool disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (disposed) return const <SearchResult>[];

  return ref.read(stockRepositoryProvider).search(trimmed);
}
