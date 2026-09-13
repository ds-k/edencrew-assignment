import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class WatchlistErrorBody extends StatelessWidget {
  const WatchlistErrorBody({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: context.dimens.iconLg,
              color: context.colors.feedbackWarning,
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              '시세를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
            ),
            SizedBox(height: context.dimens.space3),
            TextButton(
              onPressed: onRetry,
              child: Text(
                '다시 시도',
                style: TextStyle(color: context.colors.accentDefault),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
