import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/stock.dart';
import '../utils/date_converter.dart';
import '../charts/detail_chart.dart';
import '../charts/basic_chart.dart';

class StockDetailsScreen extends StatelessWidget {
  final Stock stock;

  const StockDetailsScreen({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${stock.exchange} - ${stock.currency}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${stock.quote.close}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: stock.isQuoteCloseDifferencePositive()
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stock.getFormattedChange(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: stock.isQuoteCloseDifferencePositive()
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            stock.getFormattedPercentageChange(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: stock.isQuoteCloseDifferencePositive()
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BasicChart(stock: stock),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Detailed Chart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 250, child: DetailChart(stockList: [stock])),
                  SizedBox(height: 16),
                  Text(
                    'Historical Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Open')),
                      DataColumn(label: Text('High')),
                      DataColumn(label: Text('Low')),
                      DataColumn(label: Text('Close')),
                      DataColumn(label: Text('Volume')),
                    ],
                    rows: stock.daily
                        .map(
                          (daily) => DataRow(
                        cells: [
                          DataCell(Text(convertDate(daily.dateTime, 'MM/dd/yyyy'))),
                          DataCell(Text(daily.open)),
                          DataCell(Text(daily.high)),
                          DataCell(Text(daily.low)),
                          DataCell(Text(daily.close)),
                          DataCell(Text(daily.volume)),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
