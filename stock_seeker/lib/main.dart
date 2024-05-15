import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'charts/basic_chart.dart';
import 'charts/detail_chart.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StockList stockList;
  bool loaded = false;

  // Create a list of boolean values to keep track of the loaded stocks
  List<bool> loadedStocks = [];

  @override
  void initState() {
    super.initState();
    stockList = StockList(['AAPL', 'TSLA', 'GOOGL', 'AMZN', 'IBM']);
    loadedStocks = List.filled(stockList.stocks.length, false);
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    for (var stock in stockList.stocks) {
      await stock.fetchData(symbol: stock.symbol);
      setState(() {
        loadedStocks[stockList.stocks.indexOf(stock)] = true;
        loaded = loadedStocks.every((element) => element == true);
      });
    }
  }

  // Function to filter the stocks that are loaded
  bool isStockLoaded(Stock stock) {
    return loadedStocks[stockList.stocks.indexOf(stock)];
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
            if (stockList.stocks
                .where((stock) => isStockLoaded(stock) == true)
                .toList()
                .isNotEmpty)
              SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child:
                            BasicChart(stock: stockList.stocks
                            .where((stock) => isStockLoaded(stock) == true)
                            .toList()[0]),

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
