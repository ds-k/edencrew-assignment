import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../data/models/stock.dart';
import '../../../state/favorites_provider.dart';
import '../../../theme/theme.dart';

class DetailHeader extends ConsumerWidget {
  const DetailHeader({super.key, required this.stock});

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
