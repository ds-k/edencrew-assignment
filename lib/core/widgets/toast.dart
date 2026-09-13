import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'app_icon.dart';

/// 관심 등록/해제 토스트. 화면 하단(공유 탭바 바로 위)에 2초간 떠 있다가 사라진다.
void showFavoriteToast(BuildContext context, {required bool registered}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.symmetric(
          horizontal: context.dimens.space4,
          vertical: context.dimens.space3,
        ),
        padding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.space4,
            vertical: context.dimens.space3,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceOverlay,
            borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              AppIcon(
                registered ? 'ico_starFill.svg' : 'ico_starEmpty.svg',
                size: context.dimens.iconMd,
                color: registered
                    ? context.colors.favoriteActive
                    : context.colors.favoriteInactive,
              ),
              SizedBox(width: context.dimens.space2),
              Expanded(
                child: Text(
                  registered ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
