import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/row_divider.dart';
import '../../../core/widgets/stock_row.dart';
import '../../../data/models/stock.dart';
import '../../../state/favorites_provider.dart';
import '../../../theme/theme.dart';
import '../../detail/detail_view.dart';
import 'watchlist_empty_body.dart';

class WatchlistBody extends ConsumerWidget {
  const WatchlistBody({super.key, required this.stocks});

  final List<Stock> stocks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stocks.isEmpty) return const WatchlistEmptyBody();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: stocks.length,
      separatorBuilder: (_, _) => const RowDivider(),
      itemBuilder: (BuildContext context, int index) {
        final Stock stock = stocks[index];
        return Dismissible(
          key: ValueKey<String>(stock.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) =>
              ref.read(favoritesProvider.notifier).remove(stock.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
            color: context.colors.feedbackWarning,
            child: Icon(Icons.delete, color: context.colors.textPrimary),
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DetailScreen(symbol: stock.symbol),
              ),
            ),
            child: StockRow(
              name: Text(
                stock.name,
                overflow: TextOverflow.ellipsis,
                style: StockRow.nameStyle(context),
              ),
              subtitle: '${stock.symbol} · ${stock.market}',
              trailing: PriceText(stock: stock),
            ),
          ),
        );
      },
    );
  }
}
