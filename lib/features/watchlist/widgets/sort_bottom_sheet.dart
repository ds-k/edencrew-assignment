import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';
import '../sort_order.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SortOrder selected = ref.watch(selectedSortOrderProvider);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.dimens.radiusLg),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.dimens.space4),
              child: Text(
                '정렬',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ),
            for (final SortOrder order in SortOrder.values)
              InkWell(
                onTap: () {
                  ref.read(selectedSortOrderProvider.notifier).select(order);
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: context.dimens.rowMinHeight,
                  child: Row(
                    children: <Widget>[
                      Text(
                        order.label,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 15,
                          fontWeight: AppTypography.regular,
                        ),
                      ),
                      const Spacer(),
                      if (order == selected)
                        AppIcon(
                          'ico_check.svg',
                          size: context.dimens.iconMd,
                          color: context.colors.textPrimary,
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: context.dimens.space2),
          ],
        ),
      ),
    );
  }
}
