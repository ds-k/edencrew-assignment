import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/abbreviation_format.dart';
import '../../core/utils/price_format.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/stock.dart';
import '../../state/favorites_provider.dart';
import '../../theme/theme.dart';
import 'detail_viewmodel.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Stock> asyncStock = ref.watch(
      detailViewModelProvider(symbol),
    );

    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: asyncStock.when(
          data: (Stock stock) => _DetailBody(stock: stock),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text(
              '종목 정보를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Header(stock: stock),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
          child: _PriceSection(stock: stock),
        ),
        SizedBox(height: context.dimens.space4),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
          child: _SummaryCards(stock: stock),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFavorite = ref.watch(favoritesProvider).contains(stock.id);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space2,
        vertical: context.dimens.space2,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  stock.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                Text(
                  '${stock.symbol} · ${stock.market}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    fontWeight: AppTypography.regular,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(stock.id),
            icon: AppIcon(
              isFavorite ? 'ico_starFill.svg' : 'ico_starEmpty.svg',
              size: context.dimens.iconMd,
              color: isFavorite
                  ? context.colors.favoriteActive
                  : context.colors.favoriteInactive,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    if (!stock.hasQuote) {
      return Text(
        '시세 정보 없음',
        style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
      );
    }

    final (IconData icon, Color color) = switch (stock.direction) {
      PriceDirection.up => (Icons.arrow_drop_up, context.colors.priceUpText),
      PriceDirection.down => (
        Icons.arrow_drop_down,
        context.colors.priceDownText,
      ),
      PriceDirection.flat => (Icons.remove, context.colors.priceFlatText),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          formatPrice(stock.price!),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 32,
            fontWeight: AppTypography.bold,
          ),
        ),
        SizedBox(height: context.dimens.space1),
        Row(
          children: <Widget>[
            Icon(icon, color: color, size: context.dimens.iconMd),
            Text(
              formatPriceChange(stock.priceChange!, stock.changeRate!),
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    final String dash = '-';

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _SummaryCard(
                label: '시가',
                value: stock.open != null ? formatPrice(stock.open!) : dash,
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _SummaryCard(
                label: '고가',
                value: stock.high != null ? formatPrice(stock.high!) : dash,
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _SummaryCard(
                label: '저가',
                value: stock.low != null ? formatPrice(stock.low!) : dash,
              ),
            ),
          ],
        ),
        SizedBox(height: context.dimens.space2),
        Row(
          children: <Widget>[
            Expanded(
              child: _SummaryCard(
                label: '거래량',
                value: stock.volume != null
                    ? formatVolume(stock.volume!)
                    : dash,
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _SummaryCard(
                label: '시가총액',
                value: stock.marketCap != null
                    ? formatMarketCap(stock.marketCap!)
                    : dash,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dimens.space3),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: context.dimens.space1),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}
