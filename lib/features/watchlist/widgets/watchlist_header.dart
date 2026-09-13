import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';
import '../sort_order.dart';
import '../watchlist_viewmodel.dart';
import 'sort_bottom_sheet.dart';

class WatchlistHeader extends ConsumerWidget {
  const WatchlistHeader({super.key, required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SortOrder sortOrder = ref.watch(selectedSortOrderProvider);

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
          InkWell(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const SortBottomSheet(),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  sortOrder.label,
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
          ),
          SizedBox(width: context.dimens.space2),
          IconButton(
            onPressed: isRefreshing
                ? null
                : () =>
                      ref.read(watchlistViewModelProvider.notifier).refresh().ignore(),
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
