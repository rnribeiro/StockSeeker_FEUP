import 'package:flutter/material.dart';
import 'charts/basic_chart.dart';
import 'data/stock.dart';
import './screens/stock_details_screen.dart';

typedef SelectedCallback = Function(Stock stock, bool selected);

class StockCard extends StatelessWidget {
  StockCard({
    required this.stock,
    required this.selected,
    required this.onSelected,
  }) : super(key: ObjectKey(stock));

  final Stock stock;
  final bool selected;
  final SelectedCallback onSelected;

  CircleAvatar _getAvatar(BuildContext context) {
    if (!selected) {
      return CircleAvatar(
        radius: 20,
        foregroundImage: NetworkImage(stock.logoUrl),
      );
    }
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.redAccent,
      child: Icon(Icons.check, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: selected ? Colors.blueGrey.shade50 : Colors.white,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailsScreen(stockList: [stock]),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        leading: GestureDetector(
            onTap: () {
              onSelected(stock, selected);
            },
            child: _getAvatar(context)),
        title: Text(
          stock.symbol,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          stock.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          maxLines: 1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 50,
              child: BasicChart(stock: stock),
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stock.currency == 'USD' ? '\$' : ''}${stock.quote.close}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${stock.quote.percentChange}%',
                  style: TextStyle(
                    color: stock.isQuoteCloseDifferencePositive()
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
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

  // List of selected stocks
  final _selectedStocks = <Stock>{};

  final  _filters = <String>["Sort by name ASC", "Sort by name DSC", "Sort by % change ASC", "Sort by % change DSC"];

  String _selectedFilter = "Sort by name ASC";

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case "Sort by name ASC":
          stockList.sortBySymbol(asc: true);
          break;
        case "Sort by name DSC":
          stockList.sortBySymbol(asc: false);
          break;
        case "Sort by % change ASC":
          stockList.sortByPercentageChange(asc: true);
          break;
        case "Sort by % change DSC":
          stockList.sortByPercentageChange(asc: false);
          break;
      }
    });
  }

  void _handleStockSelection(Stock stock, bool selected) {
    setState(() {
      if (!selected && _selectedStocks.length < 2) {
        _selectedStocks.add(stock);
      } else {
        _selectedStocks.remove(stock);
      }
    });
  }

  Widget _getFloatingActionButton() {
    if (_selectedStocks.length == 2) {
      return FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.stacked_line_chart, color: Colors.white),
        onPressed: () {
          List<Stock> tempList = _selectedStocks.toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StockDetailsScreen(stockList: tempList),
            ),
          );
          // clear selectedStocks
          setState(() {
            _selectedStocks.clear();
          });
        },
      );
    }
    return Container();
  }

  @override
  void initState() {
    super.initState();
    stockList = StockList([
      'AAPL', 'IBM', 'HPE',
      'MSFT', 'ORCL', 'GOOGL', 'META', 'X', 'INTC', 'AMZN'
    ]);
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
    _handleFilterChange(_selectedFilter);
  }

  // Function to filter the stocks that are loaded
  bool isStockLoaded(Stock stock) {
    return loadedStocks[stockList.stocks.indexOf(stock)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StockSeeker", style: TextStyle(color: Colors.black, fontFamily: 'Montserrat')),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet<dynamic>(isScrollControlled: true, context: context, builder: (context) {
                return Wrap(
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
                    for (var filter in _filters)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 26),
                        title: Text(filter),
                        trailing: filter == _selectedFilter
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          _handleFilterChange(filter);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                );
              });
            },
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
      body: loaded
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              itemCount: stockList.stocks.length,
              itemBuilder: (context, index) {
                return StockCard(
                  stock: stockList.stocks[index],
                  selected: _selectedStocks.contains(stockList.stocks[index]),
                  onSelected: _handleStockSelection,
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueGrey,
                    strokeWidth: 4,
                  ),
                ],
              ),
            ),
    );
  }
}
