import 'package:flutter/material.dart';
import '../data/stock.dart';
import '../charts/detail_chart.dart';

class StockDetailsScreen extends StatefulWidget {
  final List<Stock> stockList;

  get colors => [Colors.lightBlue, Colors.orange];

  const StockDetailsScreen({super.key, required this.stockList});

  @override
  _StockDetailsScreenState createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStockInfo(),
            const SizedBox(height: 10),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stockList[0].name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.stockList[0].symbol,
                      style: const TextStyle(
                          fontSize: 18, color: Colors.lightBlue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.stockList[0].quote.close}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.stockList[0].quote.percentChange}%',
                      style: TextStyle(
                        color:
                            widget.stockList[0].isQuoteCloseDifferencePositive()
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.stockList.map((stock) {
              return Expanded(
                // Wrap each stock's information in Expanded
                child: Column(
                  crossAxisAlignment: widget.stockList.indexOf(stock) == 0
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      stock.symbol,
                      style: TextStyle(
                          fontSize: 18,
                          color:
                              widget.colors[widget.stockList.indexOf(stock)]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '\$${stock.quote.close}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.stockList[0].quote.percentChange}%',
                      style: TextStyle(
                        color:
                            widget.stockList[0].isQuoteCloseDifferencePositive()
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
  }

  Widget _buildPriceDetails() {
    final isSingleStock = widget.stockList.length == 1;
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(80.0), // Label column
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: isSingleStock
          ? [
              _buildPriceDetailRow('Open', widget.stockList[0].quote.open),
              _buildPriceDetailRow('Close', widget.stockList[0].quote.close),
              _buildPriceDetailRow('High', widget.stockList[0].quote.high),
              _buildPriceDetailRow('Low', widget.stockList[0].quote.low),
            ]
          : [
              TableRow(
                children: [
                  const SizedBox(width: 60),
                  Center(
                      child: Text(widget.stockList[0].symbol,
                          style: TextStyle(
                              fontSize: 18, color: widget.colors[0]))),
                  Center(
                      child: Text(widget.stockList[1].symbol,
                          style: TextStyle(
                              fontSize: 18, color: widget.colors[1]))),
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

  TableRow _buildPriceDetailRow(String label, String value) {
    return TableRow(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Center(
          child: Text(
            '\$$value',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(), // Empty cell for single stock
      ],
    );
  }

  TableRow _buildPriceDetailRowComparison(
      String label, String value1, String value2) {
    return TableRow(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Center(
          child: Text(
            '\$$value1',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Center(
          child: Text(
            '\$$value2',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChart() {
    return SizedBox(
      height: 400,
      child: DetailChart(
        stockList: widget.stockList, // Passing the stock list
      ),
    );
  }
}
