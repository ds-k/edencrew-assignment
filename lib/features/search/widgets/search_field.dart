import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dimens.space4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space3),
        decoration: BoxDecoration(
          color: context.colors.surfaceOverlay,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            AppIcon(
              'ico_search.svg',
              size: context.dimens.iconMd,
              color: context.colors.textTertiary,
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(color: context.colors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '종목명 또는 종목코드',
                  hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: AppIcon(
                  'ico_x.svg',
                  size: context.dimens.iconSm,
                  color: context.colors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
