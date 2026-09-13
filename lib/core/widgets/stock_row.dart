import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 관심/검색 화면이 공유하는 종목 목록 행. 오른쪽 슬롯(`trailing`)만 화면별로 다르다
/// (관심: [PriceText], 검색: 관심 등록 별 아이콘).
class StockRow extends StatelessWidget {
  const StockRow({
    super.key,
    required this.name,
    required this.subtitle,
    required this.trailing,
  });

  /// 종목명. 관심 화면은 [Text], 검색 화면은 하이라이트된 [Text.rich]를 넣는다.
  final Widget name;

  /// `종목코드 · 시장`.
  final String subtitle;

  final Widget trailing;

  /// [name]에 넣을 위젯이 참조할 스타일. 화면마다 다른 위젯을 넣어도 글자 모양은 통일한다.
  static TextStyle nameStyle(BuildContext context) => TextStyle(
    color: context.colors.textPrimary,
    fontSize: 16,
    fontWeight: AppTypography.medium,
  );

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
                name,
                SizedBox(height: context.dimens.space1),
                Text(
                  subtitle,
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
          SizedBox(width: context.dimens.space3),
          trailing,
        ],
      ),
    );
  }
}
