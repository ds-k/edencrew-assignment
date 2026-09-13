import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 관심/검색 목록 행 사이에 쓰는 1px 서브틀 구분선.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: context.dimens.space2,
      thickness: context.dimens.borderHairline,
      color: context.colors.borderSubtle,
    );
  }
}
