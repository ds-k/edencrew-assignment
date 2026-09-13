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

  /// 종목명.
  final String name;

  /// `종목코드 · 시장`.
  final String subtitle;

  final Widget trailing;

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
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: AppTypography.medium,
                  ),
                ),
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
