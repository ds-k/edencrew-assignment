import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// `assets/icons/`의 SVG를 지정한 색으로 틴트해서 그린다.
/// 에셋 파일 안의 색은 무시하고 항상 이 위젯에 넘긴 색(시맨틱 토큰)을 따른다.
class AppIcon extends StatelessWidget {
  const AppIcon(this.assetName, {super.key, required this.size, required this.color});

  final String assetName;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$assetName',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
