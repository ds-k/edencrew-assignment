import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_icon.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../core/widgets/stock_row.dart';
import '../../data/models/stock.dart';
import '../../state/favorites_provider.dart';
import '../../theme/theme.dart';
import 'watchlist_viewmodel.dart';

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
            _Header(isRefreshing: asyncStocks.isLoading),
            Expanded(
              child: asyncStocks.when(
                data: (List<Stock> stocks) => _WatchlistBody(stocks: stocks),
                loading: () => const _LoadingBody(),
                error: (Object error, StackTrace stackTrace) =>
                    _ErrorBody(onRetry: () {
                      ref.read(watchlistViewModelProvider.notifier).refresh();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space4,
        vertical: context.dimens.space3,
      ),
      child: Row(
        children: <Widget>[
          Text(
            '관심',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20,
              fontWeight: AppTypography.bold,
            ),
          ),
          const Spacer(),
          // 정적 표시. 탭하면 정렬 바텀시트가 열리는 동작은 아직 연결되어 있지 않다.
          Row(
            children: <Widget>[
              Text(
                '가나다순',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                  fontWeight: AppTypography.medium,
                ),
              ),
              AppIcon(
                'ico_align.svg',
                size: context.dimens.iconMd,
                color: context.colors.textSecondary,
              ),
            ],
          ),
          SizedBox(width: context.dimens.space2),
          IconButton(
            onPressed: isRefreshing
                ? null
                : () => ref.read(watchlistViewModelProvider.notifier).refresh(),
            icon: AppIcon(
              'ico_refresh.svg',
              size: context.dimens.iconMd,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistBody extends StatelessWidget {
  const _WatchlistBody({required this.stocks});

  final List<Stock> stocks;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) return const _EmptyBody();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: stocks.length,
      separatorBuilder: (_, _) => SizedBox(height: context.dimens.space2),
      itemBuilder: (BuildContext context, int index) {
        final Stock stock = stocks[index];
        return StockRow(
          name: stock.name,
          subtitle: '${stock.symbol} · ${stock.market}',
          trailing: PriceText(stock: stock),
        );
      },
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(
              'ico_starEmpty.svg',
              size: 40,
              color: context.colors.textTertiary,
            ),
            SizedBox(height: context.dimens.space4),
            Text(
              '관심 종목이 없습니다',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                fontWeight: AppTypography.regular,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBody extends ConsumerWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int favoriteCount = ref.watch(favoritesProvider).length;
    if (favoriteCount == 0) return const SizedBox.shrink();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: favoriteCount,
      separatorBuilder: (_, _) => SizedBox(height: context.dimens.space2),
      itemBuilder: (_, _) => const _FullRowSkeleton(),
    );
  }
}

class _FullRowSkeleton extends StatelessWidget {
  const _FullRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.dimens.rowMinHeight),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SkeletonBox(width: 96, height: 16),
                SizedBox(height: context.dimens.space1),
                const SkeletonBox(width: 72, height: 13),
              ],
            ),
          ),
          SizedBox(width: context.dimens.space3),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SkeletonBox(width: 72, height: 16),
              SizedBox(height: 4),
              SkeletonBox(width: 96, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 32,
              color: context.colors.feedbackWarning,
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              '시세를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
            ),
            SizedBox(height: context.dimens.space3),
            TextButton(
              onPressed: onRetry,
              child: Text(
                '다시 시도',
                style: TextStyle(color: context.colors.accentDefault),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
