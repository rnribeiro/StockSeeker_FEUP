import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';

class BasicChart extends StatelessWidget {
  const BasicChart({
    super.key,
    required this.stock,
  });

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: double.parse(stock.quote.close),
              color: stock.isQuoteCloseDifferencePositive()
                  ? Colors.green
                  : Colors.red,
              strokeWidth: 2,
              dashArray: [5, 3],
            )
          ]
        ),
        backgroundColor: Colors.transparent,
        minX: 0,
        minY: stock.daily
            .map((value) => double.parse(value.close))
            .reduce(min)
            .floorToDouble(),
        maxY: stock.daily
            .map((value) => double.parse(value.close))
            .reduce(max)
            .ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: stock.daily
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), double.parse(entry.value.close)))
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
          )
        ],
      ),
    );
  }
}
