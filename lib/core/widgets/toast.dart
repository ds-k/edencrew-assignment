import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'app_icon.dart';

/// 관심 등록/해제 토스트. 화면 하단(공유 탭바 바로 위)에서 아래→위로 슬라이드+페이드로
/// 나타나 2초간 떠 있다가, 다시 아래로 슬라이드+페이드하며 사라진다.
///
/// `ScaffoldMessenger`/`SnackBar`(기본 Material 애니메이션) 대신 `Overlay`에 직접 올려서
/// 등장/퇴장 애니메이션을 직접 정의한다.
void showFavoriteToast(BuildContext context, {required bool registered}) {
  final OverlayState overlay = Overlay.of(context);
  final double bottomInset =
      MediaQuery.of(context).padding.bottom +
      context.dimens.tabBarHeight +
      context.dimens.space3;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext context) => _AnimatedToast(
      registered: registered,
      bottomInset: bottomInset,
      onFinished: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.registered,
    required this.bottomInset,
    required this.onFinished,
  });

  final bool registered;
  final double bottomInset;
  final VoidCallback onFinished;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

  @override
  void initState() {
    super.initState();
    _show();
  }

  Future<void> _show() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _controller.reverse();
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: context.dimens.space4,
      right: context.dimens.space4,
      bottom: widget.bottomInset,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
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
                    widget.registered ? 'ico_starFill.svg' : 'ico_starEmpty.svg',
                    size: context.dimens.iconMd,
                    color: widget.registered
                        ? context.colors.favoriteActive
                        : context.colors.favoriteInactive,
                  ),
                  SizedBox(width: context.dimens.space2),
                  Expanded(
                    child: Text(
                      widget.registered ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
                      style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
