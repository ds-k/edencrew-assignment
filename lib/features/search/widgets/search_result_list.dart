import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/highlight.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/row_divider.dart';
import '../../../core/widgets/stock_row.dart';
import '../../../core/widgets/toast.dart';
import '../../../data/models/search_result.dart';
import '../../../state/favorites_provider.dart';
import '../../../theme/theme.dart';
import '../../detail/detail_view.dart';

class SearchResultList extends ConsumerWidget {
  const SearchResultList({super.key, required this.results, required this.query});

  final List<SearchResult> results;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> favorites = ref.watch(favoritesProvider);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: results.length,
      separatorBuilder: (_, _) => const RowDivider(),
      itemBuilder: (BuildContext context, int index) {
        final SearchResult result = results[index];
        final bool isFavorite = favorites.contains(result.id);

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailScreen(symbol: result.symbol),
            ),
          ),
          child: StockRow(
            name: Text.rich(
              TextSpan(
                children: highlightedSpans(
                  result.name,
                  query,
                  normal: StockRow.nameStyle(context),
                  highlight: StockRow.nameStyle(
                    context,
                  ).copyWith(color: context.colors.searchHighlight),
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: '${result.symbol} · ${result.market}',
            trailing: GestureDetector(
              onTap: () {
                ref.read(favoritesProvider.notifier).toggle(result.id);
                showFavoriteToast(context, registered: !isFavorite);
              },
              child: AppIcon(
                isFavorite ? 'ico_starFill.svg' : 'ico_starEmpty.svg',
                size: context.dimens.iconMd,
                color: isFavorite
                    ? context.colors.favoriteActive
                    : context.colors.favoriteInactive,
              ),
            ),
          ),
        );
      },
    );
  }
}
