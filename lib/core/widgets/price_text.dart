import 'package:flutter/material.dart';

import '../../data/models/stock.dart';
import '../../theme/theme.dart';
import '../utils/price_format.dart';
import 'skeleton_box.dart';

/// 현재가 + 등락액/등락률 두 줄. 시세를 아직 받지 못한 종목([Stock.hasQuote]가 `false`)은
/// 스켈레톤으로 대체한다.
class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    if (!stock.hasQuote) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SkeletonBox(width: 72, height: 16),
          SizedBox(height: context.dimens.space1),
          const SkeletonBox(width: 96, height: 14),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          formatPrice(stock.price!),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: AppTypography.medium,
          ),
        ),
        SizedBox(height: context.dimens.space1),
        Text(
          formatPriceChange(stock.priceChange!, stock.changeRate!),
          style: TextStyle(
            color: switch (stock.direction) {
              PriceDirection.up => context.colors.priceUpText,
              PriceDirection.down => context.colors.priceDownText,
              PriceDirection.flat => context.colors.priceFlatText,
            },
            fontSize: 13,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
    );
  }
}
