import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/price_format.dart';
import '../../../core/widgets/row_divider.dart';
import '../../../data/models/candle.dart';
import '../../../theme/theme.dart';
import '../candles_provider.dart';

class DailyPriceTable extends ConsumerWidget {
  const DailyPriceTable({super.key, required this.symbol});

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
