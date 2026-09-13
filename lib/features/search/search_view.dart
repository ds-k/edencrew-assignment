import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/highlight.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/row_divider.dart';
import '../../core/widgets/stock_row.dart';
import '../../core/widgets/toast.dart';
import '../../data/models/search_result.dart';
import '../../state/favorites_provider.dart';
import '../../theme/theme.dart';
import '../detail/detail_view.dart';
import 'search_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _SearchField(
              controller: _controller,
              onChanged: (String value) => setState(() => _query = value),
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
            Expanded(child: _Body(query: _query.trim())),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
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

class _Body extends ConsumerWidget {
  const _Body({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) return const _InitialBody();

    final AsyncValue<List<SearchResult>> asyncResults = ref.watch(
      searchResultsProvider(query),
    );

    return asyncResults.when(
      data: (List<SearchResult> results) {
        if (results.isEmpty) return _NoResultsBody(query: query);
        return _ResultList(results: results, query: query);
      },
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text(
          '검색 결과를 불러오지 못했습니다',
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}

class _InitialBody extends StatelessWidget {
  const _InitialBody();

  @override
  Widget build(BuildContext context) {
    return _MessageBody(
      asset: 'ico_search.svg',
      title: '종목을 검색해 보세요',
      message: '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
    );
  }
}

class _NoResultsBody extends StatelessWidget {
  const _NoResultsBody({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _MessageBody(
      asset: 'ico_searchEmpty.svg',
      title: '검색 결과가 없습니다',
      message: "'$query'와 일치하는 검색 결과를 찾지 못했습니다.",
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.asset,
    required this.title,
    required this.message,
  });

  final String asset;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(asset, size: context.dimens.iconLg, color: context.colors.textTertiary),
            SizedBox(height: context.dimens.space4),
            Text(
              title,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                fontWeight: AppTypography.regular,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends ConsumerWidget {
  const _ResultList({required this.results, required this.query});

  final List<SearchResult> results;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> favorites = ref.watch(favoritesProvider);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: results.length,
      separatorBuilder: (_, _) => const RowDivider(),
      itemBuilder: (BuildContext context, int index) {
        final SearchResult result = results[index];
        final bool isFavorite = favorites.contains(result.id);

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailScreen(symbol: result.symbol),
            ),
          ),
          child: StockRow(
            name: Text.rich(
              TextSpan(
                children: highlightedSpans(
                  result.name,
                  query,
                  normal: StockRow.nameStyle(context),
                  highlight: StockRow.nameStyle(
                    context,
                  ).copyWith(color: context.colors.searchHighlight),
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: '${result.symbol} · ${result.market}',
            trailing: GestureDetector(
              onTap: () {
                ref.read(favoritesProvider.notifier).toggle(result.id);
                showFavoriteToast(context, registered: !isFavorite);
              },
              child: AppIcon(
                isFavorite ? 'ico_starFill.svg' : 'ico_starEmpty.svg',
                size: context.dimens.iconMd,
                color: isFavorite
                    ? context.colors.favoriteActive
                    : context.colors.favoriteInactive,
              ),
            ),
          ),
        );
      },
    );
  }
}
