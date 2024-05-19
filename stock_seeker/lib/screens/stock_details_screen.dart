import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';
import 'package:intl/intl.dart';

class StockDetailsScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailsScreen({Key? key, required this.stock}) : super(key: key);

  @override
  _StockDetailsScreenState createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  String selectedRange = '1D';
  late List<StockValue> chartData;

  @override
  void initState() {
    super.initState();
    updateChartData();
  }

  void updateChartData() {
    setState(() {
      switch (selectedRange) {
        case '1W':
          chartData = widget.stock.getLastXDaysData(7);
          break;
        case '1M':
          chartData = widget.stock.getLastXDaysData(30);
          break;
        case '1Y':
          chartData = widget.stock.getLastXDaysData(365);
          break;
        case '5Y':
          chartData = widget.stock.getLastXDaysData(365 * 5);
          break;
        case '1D':
          chartData = widget.stock.getLastXDaysData(1);
          break;
        default:
          chartData = widget.stock.getLastXDaysData(1);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stock.name} (${widget.stock.symbol})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            _buildStockInfo(),
            SizedBox(height: 10),
            _buildDateRangeButtons(),
            SizedBox(height: 10),
            _buildPriceChart(),
            SizedBox(height: 10),
            _buildPriceDetails(),
            SizedBox(height: 10),
            _buildBuySellButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stock.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.stock.symbol,
              style: TextStyle(fontSize: 18, color: Colors.lightBlue),
            ),
          ],
        ),
        Text(
          '\$${widget.stock.quote.close}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDateRangeButtons() {
    final ranges = ['1D', '1W', '1M', '1Y', '5Y'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ranges.map((range) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: selectedRange == range ? Colors.white : Colors.black, backgroundColor: selectedRange == range ? Colors.blue : Colors.grey[300],
          ),
          onPressed: () {
            setState(() {
              selectedRange = range;
              updateChartData();
            });
          },
          child: Text(range),
        );
      }).toList(),
    );
  }

  Widget _buildPriceChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData
                  .map((value) => FlSpot(
                  DateTime.parse(value.dateTime).millisecondsSinceEpoch
                      .toDouble(),
                  double.parse(value.close)))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(DateFormat('MMM dd').format(date));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceDetailRow('Open', widget.stock.quote.open),
        _buildPriceDetailRow('Close', widget.stock.quote.close),
        _buildPriceDetailRow('High', widget.stock.quote.high),
        _buildPriceDetailRow('Low', widget.stock.quote.low),
      ],
    );
  }

  Widget _buildPriceDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            '\$${value}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Implement Buy action
          },
          child: Text('Buy'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement Sell action
          },
          child: Text('Sell'),
        ),
      ],
    );
  }
}
