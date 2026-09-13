import 'package:flutter/material.dart';

import '../../../core/utils/abbreviation_format.dart';
import '../../../core/utils/price_format.dart';
import '../../../data/models/stock.dart';
import '../../../theme/theme.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.stock});

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
