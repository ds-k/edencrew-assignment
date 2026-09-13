import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stock.dart';
import '../../theme/theme.dart';
import 'detail_viewmodel.dart';
import 'widgets/chart_section.dart';
import 'widgets/daily_price_table.dart';
import 'widgets/detail_header.dart';
import 'widgets/period_tabs.dart';
import 'widgets/price_section.dart';
import 'widgets/summary_cards.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Stock> asyncStock = ref.watch(
      detailViewModelProvider(symbol),
    );

    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: asyncStock.when(
          data: (Stock stock) => _DetailBody(stock: stock),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text(
              '종목 정보를 불러오지 못했습니다',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DetailHeader(stock: stock),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: PriceSection(stock: stock),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: const PeriodTabs(),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: ChartSection(symbol: stock.symbol),
                ),
                SizedBox(height: context.dimens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
                  child: SummaryCards(stock: stock),
                ),
                SizedBox(height: context.dimens.space5),
                DailyPriceTable(symbol: stock.symbol),
                SizedBox(height: context.dimens.space5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
