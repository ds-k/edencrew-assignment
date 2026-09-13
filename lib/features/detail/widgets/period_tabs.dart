import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/candle.dart';
import '../../../theme/theme.dart';
import '../candles_provider.dart';

class PeriodTabs extends ConsumerWidget {
  const PeriodTabs({super.key});

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
