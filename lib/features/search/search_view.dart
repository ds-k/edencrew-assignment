import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 검색 화면.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: const SafeArea(child: SizedBox.shrink()),
    );
  }
}
