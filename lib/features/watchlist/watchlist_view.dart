import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stock.dart';
import '../../state/favorites_provider.dart';
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
                data: (List<Stock> stocks) {
                  // 스와이프로 막 삭제한 종목은 재조회(네트워크)가 끝나기 전까지
                  // asyncStocks에 그대로 남아있을 수 있다 — favorites 기준으로 한 번
                  // 더 걸러서 즉시 사라지게 한다. 그렇지 않으면 같은 key의
                  // Dismissible이 dismiss 애니메이션 직후 다시 나타나 크래시난다.
                  final Set<String> favoriteIds = ref.watch(favoritesProvider);
                  final List<Stock> visible = stocks
                      .where((Stock stock) => favoriteIds.contains(stock.id))
                      .toList();

                  return RefreshIndicator(
                    color: context.colors.accentDefault,
                    onRefresh: () =>
                        ref.read(watchlistViewModelProvider.notifier).refresh(),
                    child: WatchlistBody(
                      stocks: sortStocks(
                        visible,
                        ref.watch(selectedSortOrderProvider),
                      ),
                    ),
                  );
                },
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
