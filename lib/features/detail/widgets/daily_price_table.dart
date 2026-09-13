import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/price_format.dart';
import '../../../core/widgets/row_divider.dart';
import '../../../data/models/candle.dart';
import '../../../theme/theme.dart';
import '../candles_provider.dart';

/// 무한 스크롤: 처음엔 [_initialVisibleCount]행만 그리고, [scrollController]가
/// 붙어있는 상위 스크롤(상세 화면 전체)이 바닥 근처에 닿을 때마다 더 보여준다.
/// 이미 다 받아온 데이터를 점진적으로만 렌더하는 방식이라(캔들 차트가 기간 전체
/// 데이터를 어차피 다 요청해야 해서 서버 페이지네이션은 이 구조와 안 맞음) 네트워크는
/// 그대로고 위젯 생성 개수만 줄어든다 — 1년 탭 250행을 한 번에 렌더하던 문제도 해결됨.
class DailyPriceTable extends ConsumerStatefulWidget {
  const DailyPriceTable({
    super.key,
    required this.symbol,
    required this.scrollController,
  });

  final String symbol;
  final ScrollController scrollController;

  static const int _initialVisibleCount = 15;
  static const int _loadMoreCount = 15;
  static const double _loadMoreThreshold = 200;

  @override
  ConsumerState<DailyPriceTable> createState() => _DailyPriceTableState();
}

class _DailyPriceTableState extends ConsumerState<DailyPriceTable> {
  int _visibleCount = DailyPriceTable._initialVisibleCount;

  /// 마지막으로 받은 캔들 총 개수. build()에서 매번 갱신되며, `_onScroll`이 상한을
  /// 넘어서 계속 setState하지 않도록 막는 데 쓴다.
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_visibleCount >= _totalCount) return;
    if (!widget.scrollController.hasClients) return;
    final ScrollPosition position = widget.scrollController.position;
    if (position.pixels < position.maxScrollExtent - DailyPriceTable._loadMoreThreshold) {
      return;
    }
    setState(() {
      _visibleCount = (_visibleCount + DailyPriceTable._loadMoreCount).clamp(
        0,
        _totalCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChartPeriod period = ref.watch(selectedPeriodProvider);
    final AsyncValue<List<Candle>> asyncCandles = ref.watch(
      candlesProvider(widget.symbol, period),
    );

    // 기간 탭이 바뀌면 새 데이터 기준으로 다시 15개부터 보여준다.
    ref.listen(selectedPeriodProvider, (ChartPeriod? previous, ChartPeriod next) {
      if (previous != null && previous != next) {
        setState(() => _visibleCount = DailyPriceTable._initialVisibleCount);
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '일별 시세',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: context.dimens.space3),
          asyncCandles.when(
            data: (List<Candle> candles) {
              _totalCount = candles.length;
              return _DailyPriceRows(
                candles: candles.take(_visibleCount).toList(growable: false),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => Text(
              '일별 시세를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyPriceRows extends StatelessWidget {
  const _DailyPriceRows({required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = TextStyle(
      color: context.colors.textSecondary,
      fontSize: 12,
      fontWeight: AppTypography.medium,
    );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(flex: 2, child: Text('날짜', style: headerStyle)),
            Expanded(
              flex: 3,
              child: Text('종가', textAlign: TextAlign.right, style: headerStyle),
            ),
            Expanded(
              flex: 3,
              child: Text('등락', textAlign: TextAlign.right, style: headerStyle),
            ),
            Expanded(
              flex: 4,
              child: Text('거래량', textAlign: TextAlign.right, style: headerStyle),
            ),
          ],
        ),
        SizedBox(height: context.dimens.space2),
        for (final Candle candle in candles) ...<Widget>[
          const RowDivider(),
          _DailyPriceRow(candle: candle),
        ],
      ],
    );
  }
}

class _DailyPriceRow extends StatelessWidget {
  const _DailyPriceRow({required this.candle});

  final Candle candle;

  @override
  Widget build(BuildContext context) {
    final Color changeColor = candle.priceChange > 0
        ? context.colors.priceUpText
        : candle.priceChange < 0
        ? context.colors.priceDownText
        : context.colors.priceFlatText;
    final TextStyle valueStyle = TextStyle(
      color: context.colors.textPrimary,
      fontSize: 13,
      fontWeight: AppTypography.regular,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimens.space2),
      child: Row(
        children: <Widget>[
          Expanded(flex: 2, child: Text(formatMonthDay(candle.date), style: valueStyle)),
          Expanded(
            flex: 3,
            child: Text(
              formatPrice(candle.close),
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatSignedPrice(candle.priceChange),
              textAlign: TextAlign.right,
              style: valueStyle.copyWith(color: changeColor),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              formatPrice(candle.volume),
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}
