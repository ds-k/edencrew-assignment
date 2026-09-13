import 'package:flutter/material.dart';

import '../../../core/utils/price_format.dart';
import '../../../data/models/stock.dart';
import '../../../theme/theme.dart';

class PriceSection extends StatelessWidget {
  const PriceSection({super.key, required this.stock});

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
