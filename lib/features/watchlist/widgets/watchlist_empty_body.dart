import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';

class WatchlistEmptyBody extends StatelessWidget {
  const WatchlistEmptyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(
              'ico_starEmpty.svg',
              size: context.dimens.iconLg,
              color: context.colors.textTertiary,
            ),
            SizedBox(height: context.dimens.space4),
            Text(
              '관심 종목이 없습니다',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                fontWeight: AppTypography.regular,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
