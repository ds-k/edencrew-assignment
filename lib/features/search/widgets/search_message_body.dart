import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';
import '../recent_searches_provider.dart';

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

class SearchInitialBody extends ConsumerWidget {
  const SearchInitialBody({super.key, required this.onSelectQuery});

  final ValueChanged<String> onSelectQuery;

  static const Widget _guide = SearchMessageBody(
    asset: 'ico_search.svg',
    title: '종목을 검색해 보세요',
    message: '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> recent = ref.watch(recentSearchesProvider);
    if (recent.isEmpty) return _guide;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.space4,
            vertical: context.dimens.space3,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '최근 검색어',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: AppTypography.medium,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                child: Text(
                  '전체 삭제',
                  style: TextStyle(color: context.colors.textTertiary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
          child: Wrap(
            spacing: context.dimens.space2,
            runSpacing: context.dimens.space2,
            children: <Widget>[
              for (final String query in recent)
                _RecentSearchChip(
                  query: query,
                  onTap: () => onSelectQuery(query),
                ),
            ],
          ),
        ),
        const Expanded(child: _guide),
      ],
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  const _RecentSearchChip({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.space3,
          vertical: context.dimens.space2,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceOverlay,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        child: Text(
          query,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
        ),
      ),
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
