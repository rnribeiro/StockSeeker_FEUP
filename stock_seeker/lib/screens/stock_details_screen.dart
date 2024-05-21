import 'package:flutter/material.dart';
import '../data/stock.dart';
import '../charts/detail_chart.dart';

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
        case '1D':
          chartData = widget.stock.getLastXDaysData(1);
          break;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStockInfo(),
            const SizedBox(height: 20),
            _buildDateRangeButtons(),
            const SizedBox(height: 20),
            _buildPriceChart(),
            const SizedBox(height: 20),
            _buildPriceDetails(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    return Column(
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
        SizedBox(height: 10),
        Text(
          '\$${widget.stock.quote.close}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDateRangeButtons() {
    final ranges = ['1D', '1W', '1M', '1Y', '5Y'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ranges.map((range) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: selectedRange == range
                    ? Colors.blue
                    : Colors.grey[300],
              ),
              onPressed: () {
                setState(() {
                  selectedRange = range; // Update selectedRange
                });
                updateChartData(); // Call updateChartData
              },
              child: Text(range),
            ),
          );
        }).toList(),
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

  Widget _buildPriceChart() {
    return Expanded(
      child: Container(
        height: 200,
        child: DetailChart(
          stockList: [widget.stock], // Passing single stock data
        ),
      ),
    );
  }


}
