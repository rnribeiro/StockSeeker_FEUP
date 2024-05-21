import 'package:flutter/material.dart';
import '../data/stock.dart';
import '../charts/detail_chart.dart';

class StockDetailsScreen extends StatelessWidget {
  final Stock stock;

  const StockDetailsScreen({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${stock.name} (${stock.symbol})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStockInfo(),
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
          stock.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          stock.symbol,
          style: TextStyle(fontSize: 18, color: Colors.lightBlue),
        ),
        SizedBox(height: 10),
        Text(
          '\$${stock.quote.close}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPriceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceDetailRow('Open', stock.quote.open),
        _buildPriceDetailRow('Close', stock.quote.close),
        _buildPriceDetailRow('High', stock.quote.high),
        _buildPriceDetailRow('Low', stock.quote.low),
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
          stockList: [stock], // Pass the stock object to DetailChart
        ),
      ),
    );
  }
}
