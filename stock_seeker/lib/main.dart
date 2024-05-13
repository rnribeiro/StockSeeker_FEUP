import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'data/stock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockSeeker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

// Function to convert a date from 'yyyy-MM-dd' to 'Month. dd'
String convertDate(String date) {
  var parsedDate = DateTime.parse(date);
  var formatter = DateFormat('MMM. dd');
  return formatter.format(parsedDate);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StockList stockList;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    stockList = StockList(['IBM', 'META']);
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    for (var stock in stockList.stocks) {
      await stock.fetchData(symbol: stock.symbol, outputSize: 30);
    }
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("StockSeeker"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stock Price Chart',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (loaded)
              SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                // reservedSize: 40,
                                interval: 5,
                                getTitlesWidget: (value, meta) =>
                                    SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 5,
                                        child: Text(convertDate(stockList.stocks.first
                                                .values[value.toInt()].dateTime)))),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        minY: stockList.stocks
                            .map((stock) => stock.values
                                .map((value) => double.parse(value.close))
                                .reduce(min))
                            .reduce(min)
                            .floorToDouble(),
                        maxY: stockList.stocks
                            .map((stock) => stock.values
                                .map((value) => double.parse(value.close))
                                .reduce(max))
                            .reduce(max)
                            .ceilToDouble(),
                        lineBarsData: stockList.stocks
                            .map((stock) => LineChartBarData(
                                  spots: stock.values
                                      .asMap()
                                      .entries
                                      .map((entry) => FlSpot(
                                          entry.key.toDouble(),
                                          double.parse(entry.value.close)))
                                      .toList(),
                                  isCurved: true,
                                  preventCurveOverShooting: true,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  isStrokeJoinRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: true),
                                  color: stock.isCloseDifferencePositive()
                                      ? Colors.green
                                      : Colors.red,
                                ))
                            .toList(),
                      ),
                    ),
                  ))
            else
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 4,
              ),
          ],
        ),
      ),
    );
  }
}
