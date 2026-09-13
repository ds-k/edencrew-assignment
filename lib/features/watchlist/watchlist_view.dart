import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stock.dart';
import '../../theme/theme.dart';
import 'sort_order.dart';
import 'watchlist_viewmodel.dart';
import 'widgets/watchlist_body.dart';
import 'widgets/watchlist_error_body.dart';
import 'widgets/watchlist_header.dart';
import 'widgets/watchlist_loading_body.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Stock>> asyncStocks = ref.watch(
      watchlistViewModelProvider,
    );

    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            WatchlistHeader(isRefreshing: asyncStocks.isLoading),
            Expanded(
              child: asyncStocks.when(
                skipLoadingOnReload: true,
                data: (List<Stock> stocks) => RefreshIndicator(
                  color: context.colors.accentDefault,
                  onRefresh: () =>
                      ref.read(watchlistViewModelProvider.notifier).refresh(),
                  child: WatchlistBody(
                    stocks: sortStocks(stocks, ref.watch(selectedSortOrderProvider)),
                  ),
                ),
                loading: () => const WatchlistLoadingBody(),
                error: (Object error, StackTrace stackTrace) =>
                    WatchlistErrorBody(onRetry: () {
                      ref.read(watchlistViewModelProvider.notifier).refresh().ignore();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
