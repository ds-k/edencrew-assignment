import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';

/// 검색 초기 상태 / 결과 없음 상태가 공유하는 레이아웃(아이콘 + 제목 + 안내 문구).
class SearchMessageBody extends StatelessWidget {
  const SearchMessageBody({
    super.key,
    required this.asset,
    required this.title,
    required this.message,
  });

  final String asset;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(asset, size: context.dimens.iconLg, color: context.colors.textTertiary),
            SizedBox(height: context.dimens.space4),
            Text(
              title,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              message,
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

class SearchInitialBody extends StatelessWidget {
  const SearchInitialBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchMessageBody(
      asset: 'ico_search.svg',
      title: '종목을 검색해 보세요',
      message: '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
    );
  }
}

class SearchNoResultsBody extends StatelessWidget {
  const SearchNoResultsBody({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return SearchMessageBody(
      asset: 'ico_searchEmpty.svg',
      title: '검색 결과가 없습니다',
      message: "'$query'와 일치하는 검색 결과를 찾지 못했습니다.",
    );
  }
}
