import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/abbreviation_format.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/price_format.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/row_divider.dart';
import '../../data/models/candle.dart';
import '../../data/models/stock.dart';
import '../../state/favorites_provider.dart';
import '../../theme/theme.dart';
import 'candle_chart.dart';
import 'candles_provider.dart';
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: _PriceSection(stock: stock),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: const _PeriodTabs(),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: _ChartSection(symbol: stock.symbol),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: _SummaryCards(stock: stock),
                ),
                SizedBox(height: context.dimens.space5),
                _DailyPriceTable(symbol: stock.symbol),
                SizedBox(height: context.dimens.space5),
              ],
            ),
          ),
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

class _PeriodTabs extends ConsumerWidget {
  const _PeriodTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChartPeriod selected = ref.watch(selectedPeriodProvider);

    return Row(
      children: <Widget>[
        for (final ChartPeriod period in ChartPeriod.values)
          Expanded(
            child: _PeriodTab(
              period: period,
              selected: period == selected,
              onTap: () =>
                  ref.read(selectedPeriodProvider.notifier).select(period),
            ),
          ),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final ChartPeriod period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.space3,
          vertical: context.dimens.space2,
        ),
        decoration: BoxDecoration(
          color: selected ? context.colors.accentBg : null,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        child: Text(
          period.label,
          style: TextStyle(
            color: selected
                ? context.colors.accentDefault
                : context.colors.textSecondary,
            fontSize: 13,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  const _ChartSection({required this.symbol});

  final String symbol;

  /// 시안과 정확히 같을 필요는 없다(ASSIGNMENT.md) — 위아래 요소 배치만 어긋나지
  /// 않으면 되는 고정 높이.
  static const double _height = 220;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChartPeriod period = ref.watch(selectedPeriodProvider);
    final AsyncValue<List<Candle>> asyncCandles = ref.watch(
      candlesProvider(symbol, period),
    );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: asyncCandles.when(
        data: (List<Candle> candles) {
          if (candles.length < 2) {
            return Center(
              child: Text(
                '차트를 표시할 데이터가 부족합니다',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
            );
          }
          return CandleChart(candles: candles);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text(
            '차트를 불러오지 못했습니다',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ),
      ),
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

class _DailyPriceTable extends ConsumerWidget {
  const _DailyPriceTable({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChartPeriod period = ref.watch(selectedPeriodProvider);
    final AsyncValue<List<Candle>> asyncCandles = ref.watch(
      candlesProvider(symbol, period),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '일별 시세',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: context.dimens.space3),
          asyncCandles.when(
            data: (List<Candle> candles) => _DailyPriceRows(candles: candles),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => Text(
              '일별 시세를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyPriceRows extends StatelessWidget {
  const _DailyPriceRows({required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = TextStyle(
      color: context.colors.textSecondary,
      fontSize: 12,
      fontWeight: AppTypography.medium,
    );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(flex: 2, child: Text('날짜', style: headerStyle)),
            Expanded(
              flex: 3,
              child: Text('종가', textAlign: TextAlign.right, style: headerStyle),
            ),
            Expanded(
              flex: 3,
              child: Text('등락', textAlign: TextAlign.right, style: headerStyle),
            ),
            Expanded(
              flex: 4,
              child: Text('거래량', textAlign: TextAlign.right, style: headerStyle),
            ),
          ],
        ),
        SizedBox(height: context.dimens.space2),
        for (final Candle candle in candles) ...<Widget>[
          const RowDivider(),
          _DailyPriceRow(candle: candle),
        ],
      ],
    );
  }
}

class _DailyPriceRow extends StatelessWidget {
  const _DailyPriceRow({required this.candle});

  final Candle candle;

  @override
  Widget build(BuildContext context) {
    final Color changeColor = candle.priceChange > 0
        ? context.colors.priceUpText
        : candle.priceChange < 0
        ? context.colors.priceDownText
        : context.colors.priceFlatText;
    final TextStyle valueStyle = TextStyle(
      color: context.colors.textPrimary,
      fontSize: 13,
      fontWeight: AppTypography.regular,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimens.space2),
      child: Row(
        children: <Widget>[
          Expanded(flex: 2, child: Text(formatMonthDay(candle.date), style: valueStyle)),
          Expanded(
            flex: 3,
            child: Text(
              formatPrice(candle.close),
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatSignedPrice(candle.priceChange),
              textAlign: TextAlign.right,
              style: valueStyle.copyWith(color: changeColor),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              formatPrice(candle.volume),
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}
