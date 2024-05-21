import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';
import '../utils/date_converter.dart';

class DetailChart extends StatefulWidget {
  const DetailChart({
    Key? key,
    required this.stockList,
  }) : super(key: key);

  final List<Stock> stockList;

  @override
  _DetailChartState createState() => _DetailChartState();
}

class _DetailChartState extends State<DetailChart> {
  String _selectedTimeframe = '1D';

  List<StockValue> _getFilteredData(Stock stock) {
    switch (_selectedTimeframe) {
      case '1D':
        return stock.getLastXDaysData(1);
      case '1W':
        return stock.getLastXDaysData(7);
      case '1M':
        return stock.getLastXDaysData(30);
      case '3M':
        return stock.getLastXDaysData(90);
      case '6M':
        return stock.getLastXDaysData(180);
      default:
        return stock.getLastXDaysData(1);
    }
  }

  Widget _buildButton(String timeframe) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTimeframe = timeframe;
          });
        },
        child: Text(timeframe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1D', '1W', '1M', '3M', '6M']
              .map((timeframe) => _buildButton(timeframe))
              .toList(),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 60,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 5,
                      child: Text(convertDate(
                          widget.stockList.first.daily[value.toInt()].dateTime, 'HH')),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              minY: widget.stockList
                  .map((stock) => _getFilteredData(stock)
                  .map((value) => double.parse(value.close))
                  .reduce(min))
                  .reduce(min)
                  .floorToDouble(),
              maxY: widget.stockList
                  .map((stock) => _getFilteredData(stock)
                  .map((value) => double.parse(value.close))
                  .reduce(max))
                  .reduce(max)
                  .ceilToDouble(),
              lineBarsData: widget.stockList
                  .map((stock) => LineChartBarData(
                spots: _getFilteredData(stock)
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
          ),
        ),
      ],
    );
  }
}
