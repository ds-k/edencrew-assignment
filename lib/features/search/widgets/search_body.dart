import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/search_result.dart';
import '../../../theme/theme.dart';
import '../search_viewmodel.dart';
import 'search_message_body.dart';
import 'search_result_list.dart';

class SearchBody extends ConsumerWidget {
  const SearchBody({super.key, required this.query, required this.onSelectQuery});

  final String query;
  final ValueChanged<String> onSelectQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) return SearchInitialBody(onSelectQuery: onSelectQuery);

    final AsyncValue<List<SearchResult>> asyncResults = ref.watch(
      searchResultsProvider(query),
    );

    return asyncResults.when(
      data: (List<SearchResult> results) {
        if (results.isEmpty) return SearchNoResultsBody(query: query);
        return SearchResultList(results: results, query: query);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text(
          '검색 결과를 불러오지 못했습니다',
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}
