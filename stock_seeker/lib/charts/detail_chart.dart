import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';
import '../utils/date_converter.dart';


class DetailChart extends StatelessWidget {
  const DetailChart({
    super.key,
    required this.stockList,
  });

  final List<Stock> stockList;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                // reservedSize: 40,
                interval: 60,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 5,
                    child: Text(convertDate(
                        stockList.first.daily[value.toInt()].dateTime, 'HH')))),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        minY: stockList
            .map((stock) => stock.daily
            .map((value) => double.parse(value.close))
            .reduce(min))
            .reduce(min)
            .floorToDouble(),
        maxY: stockList
            .map((stock) => stock.daily
            .map((value) => double.parse(value.close))
            .reduce(max))
            .reduce(max)
            .ceilToDouble(),
        lineBarsData: stockList
            .map((stock) => LineChartBarData(
          spots: stock.daily
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(),
              double.parse(entry.value.close)))
              .toList(),
          isCurved: true,
          preventCurveOverShooting: true,
          barWidth: 3,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: false,
          ),
          color: stock.isQuoteCloseDifferencePositive()
              ? Colors.green
              : Colors.red,
        ))
            .toList(),
      ),
    );
  }
}
