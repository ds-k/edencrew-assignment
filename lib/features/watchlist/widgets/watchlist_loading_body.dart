import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../../../state/favorites_provider.dart';
import '../../../theme/theme.dart';

class WatchlistLoadingBody extends ConsumerWidget {
  const WatchlistLoadingBody({super.key});

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SkeletonBox(width: 72, height: 16),
              SizedBox(height: context.dimens.space1),
              const SkeletonBox(width: 96, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
