import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 시세를 아직 받지 못한 자리에 채우는 회색 박스. `feedbackSkeleton` 토큰 사용.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusSm),
      ),
    );
  }
}
