import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';
import '../utils/date_converter.dart';

class DetailChart extends StatefulWidget {
  const DetailChart({
    super.key,
    required this.stockList,
  });

  final List<Stock> stockList;

  get colors => [Colors.lightBlue, Colors.orange];

  @override
  _DetailChartState createState() => _DetailChartState();
}

class _DetailChartState extends State<DetailChart> {
  String _selectedTimeframe = '1D';

  List<StockValue> _getFilteredData(Stock stock) {
    switch (_selectedTimeframe) {
      case '1D':
        return stock.daily;
      case '1W':
        return stock.getLastXWeekdaysData(7);
      case '1M':
        return stock.getLastXWeekdaysData(30);
      case '3M':
        return stock.getLastXWeekdaysData(90);
      case '6M':
        return stock.getLastXWeekdaysData(180);
      default:
        return stock.daily;
    }
  }

  void _updateSelectedTimeframe(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
  }

  double _getMaxLabelWidth(List<StockValue> data) {
    final labels = data
        .map((value) => double.parse(value.close).toStringAsFixed(2))
        .toList();
    double maxWidth = 0.0;

    for (var label in labels) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }
    return maxWidth;
  }

  Widget _buildDateRangeButtons() {
    final ranges = ['1D', '1W', '1M', '3M', '6M'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ranges.map((range) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            // Reduced padding
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0), // Reduced button size
                textStyle: const TextStyle(fontSize: 12), // Smaller text
                foregroundColor: Colors.white,
                backgroundColor: _selectedTimeframe == range
                    ? Colors.blue
                    : Colors.grey[300],
              ),
              onPressed: () {
                _updateSelectedTimeframe(range);
              },
              child: Text(range),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDataList =
        widget.stockList.map((stock) => _getFilteredData(stock)).toList();
    final int maxLength =
        filteredDataList.map((data) => data.length).reduce(max);
    final maxLabelWidth =
        _getMaxLabelWidth(filteredDataList.expand((data) => data).toList());

    final minY = filteredDataList
        .expand((data) => data)
        .map((value) => double.parse(value.close))
        .reduce(min)
        .floorToDouble();
    final maxY = filteredDataList
        .expand((data) => data)
        .map((value) => double.parse(value.close))
        .reduce(max)
        .ceilToDouble();
    final yInterval = (maxY - minY) / 15; // Adjust interval to prevent overlap

    return Column(
      children: [
        _buildDateRangeButtons(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: maxLabelWidth + 5, // Dynamic reserved size
                      getTitlesWidget: (value, meta) {
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 3.0), // Added padding
                            child: Text(
                              value.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxLength / 5, // Adjust this interval as needed
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= maxLength) return Container();
                        final dateTime = filteredDataList.first[index]
                            .dateTime; // Using the first stock's dates
                        final label = _selectedTimeframe == '1D'
                            ? convertDate(dateTime, 'HH:mm')
                            : convertDate(dateTime, 'dd/MM');
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 5,
                          child: Text(label),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxLength - 1.toDouble(),
                lineBarsData: widget.stockList.map((stock) {
                  final filteredData = _getFilteredData(stock);
                  return LineChartBarData(
                      spots: filteredData
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
                      belowBarData: BarAreaData(show: false),
                      color: widget.stockList.length == 1
                          ? stock.isQuoteCloseDifferencePositive()
                              ? Colors.green
                              : Colors.red
                          : widget.colors[widget.stockList.indexOf(stock)]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
