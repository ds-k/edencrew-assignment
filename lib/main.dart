import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/preferences_provider.dart';
import 'core/widgets/app_icon.dart';
import 'features/search/search_view.dart';
import 'features/watchlist/watchlist_view.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EdencrewAssignmentApp(),
    ),
  );
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      theme: AppTheme.dark,
      home: const RootScreen(),
    );
  }
}

/// 관심/검색 화면을 하단 탭으로 전환하는 앱 진입점.
/// 종목상세는 탭이 아니라 검색/관심 화면에서 push되는 별도 화면이라 여기 포함하지 않는다.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    WatchlistScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomTabBar(
        index: _index,
        onChanged: (int index) => setState(() => _index = index),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: context.dimens.tabBarHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceBase,
            border: Border(
              top: BorderSide(
                color: context.colors.borderSubtle,
                width: context.dimens.borderHairline,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              _TabItem(
                selectedAsset: 'ico_starFill.svg',
                unselectedAsset: 'ico_starEmpty.svg',
                label: '관심',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
              _TabItem(
                selectedAsset: 'ico_search.svg',
                unselectedAsset: 'ico_search.svg',
                label: '검색',
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selectedAsset,
    required this.unselectedAsset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String selectedAsset;
  final String unselectedAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.colors.navActive
        : context.colors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIcon(
              selected ? selectedAsset : unselectedAsset,
              size: context.dimens.iconMd,
              color: color,
            ),
            SizedBox(height: context.dimens.space1),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
