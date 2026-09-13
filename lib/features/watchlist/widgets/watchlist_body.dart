import 'package:flutter/material.dart';

import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/row_divider.dart';
import '../../../core/widgets/stock_row.dart';
import '../../../data/models/stock.dart';
import '../../../theme/theme.dart';
import '../../detail/detail_view.dart';
import 'watchlist_empty_body.dart';

class WatchlistBody extends StatelessWidget {
  const WatchlistBody({super.key, required this.stocks});

  final List<Stock> stocks;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) return const WatchlistEmptyBody();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: stocks.length,
      separatorBuilder: (_, _) => const RowDivider(),
      itemBuilder: (BuildContext context, int index) {
        final Stock stock = stocks[index];
        return InkWell(
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
        );
      },
    );
  }
}
