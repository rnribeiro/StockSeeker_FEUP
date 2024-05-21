import 'package:flutter/material.dart';
import '../data/stock.dart';
import '../charts/detail_chart.dart';

class StockDetailsScreen extends StatefulWidget {
  final List<Stock> stockList;

  const StockDetailsScreen({super.key, required this.stockList});

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
          chartData = widget.stockList[0].getLastXDaysData(1);
          break;
        case '1W':
          chartData = widget.stockList[0].getLastXDaysData(7);
          break;
        case '1M':
          chartData = widget.stockList[0].getLastXDaysData(30);
          break;
        case '1Y':
          chartData = widget.stockList[0].getLastXDaysData(365);
          break;
        case '5Y':
          chartData = widget.stockList[0].getLastXDaysData(365 * 5);
          break;
        default:
          chartData = widget.stockList[0].getLastXDaysData(1);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSingleStock = widget.stockList.length == 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(isSingleStock
            ? '${widget.stockList[0].name} (${widget.stockList[0].symbol})'
            : '${widget.stockList[0].symbol} vs ${widget.stockList[1].symbol}'),
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
    final isSingleStock = widget.stockList.length == 1;
    return isSingleStock
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockList[0].name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.stockList[0].symbol,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.lightBlue),
                  ),
                ],
              ),
              Text(
                '\$${widget.stockList[0].quote.close}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockList[0].name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.stockList[0].symbol,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.lightBlue),
                  ),
                  Text(
                    '\$${widget.stockList[0].quote.close}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockList[1].name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.stockList[1].symbol,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.lightBlue),
                  ),
                  Text(
                    '\$${widget.stockList[1].quote.close}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
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
                backgroundColor:
                    selectedRange == range ? Colors.blue : Colors.grey[300],
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
    final isSingleStock = widget.stockList.length == 1;
    return isSingleStock
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceDetailRow('Open', widget.stockList[0].quote.open),
              _buildPriceDetailRow('Close', widget.stockList[0].quote.close),
              _buildPriceDetailRow('High', widget.stockList[0].quote.high),
              _buildPriceDetailRow('Low', widget.stockList[0].quote.low),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  Text(widget.stockList[0].symbol),
                  Text(widget.stockList[1].symbol),
                ],
              ),
              _buildPriceDetailRowComparison(
                  'Open',
                  widget.stockList[0].quote.open,
                  widget.stockList[1].quote.open),
              _buildPriceDetailRowComparison(
                  'Close',
                  widget.stockList[0].quote.close,
                  widget.stockList[1].quote.close),
              _buildPriceDetailRowComparison(
                  'High',
                  widget.stockList[0].quote.high,
                  widget.stockList[1].quote.high),
              _buildPriceDetailRowComparison('Low',
                  widget.stockList[0].quote.low, widget.stockList[1].quote.low),
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
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '\$$value',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailRowComparison(
      String label, String value1, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '\$$value1',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '\$$value2',
            style: const TextStyle(fontSize: 16),
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
          stockList: widget.stockList, // Passing the stock list
        ),
      ),
    );
  }
}
