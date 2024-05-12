import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StockList {
  List<Stock> stocks;

  StockList(List<String> symbols)
      : stocks = symbols.map((symbol) => Stock(symbol: symbol)).toList();

  void sortByChange({bool asc = false}) {
    stocks.sort((a, b) {
      var aChange = double.parse(a.quote.change);
      var bChange = double.parse(b.quote.change);
      return asc ? aChange.compareTo(bChange) : bChange.compareTo(aChange);
    });
  }

  void sortByPercentageChange({bool asc = false}) {
    stocks.sort((a, b) {
      var aPercentChange = double.parse(a.quote.percentChange);
      var bPercentChange = double.parse(b.quote.percentChange);
      return asc ? aPercentChange.compareTo(bPercentChange) : bPercentChange.compareTo(aPercentChange);
    });
  }

  void sortBySymbol({bool asc = true}) {
    stocks.sort((a, b) {
      return asc ? a.symbol.compareTo(b.symbol) : b.symbol.compareTo(a.symbol);
    });
  }

  void sortByName({bool asc = true}) {
    stocks.sort((a, b) {
      return asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
    });
  }
}

class Stock {
  final String symbol;
  late String name;
  late String currency;
  late String exchange;
  late List<StockValue> values;
  late String logoUrl;
  late Quote quote;

  Stock({required this.symbol}) {
    fetchData(symbol: symbol);
  }

  Future<void> fetchData({
    required String symbol,
    String interval = '1day',
    int outputSize = 200,
    int dp = 5,
    String order = 'DESC',
    bool previousClose = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    startDate ??= DateTime.now().subtract(const Duration(days: 180));

    // Format the dates
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedStartDate = dateFormatter.format(startDate);
    String? formattedEndDate =
        endDate != null ? dateFormatter.format(endDate) : null;

    var timeSeriesUrl = Uri.https('api.twelvedata.com', '/time_series', {
      'symbol': symbol,
      'interval': interval,
      'outputsize': outputSize.toString(),
      'dp': dp.toString(),
      'order': order,
      'previous_close': previousClose.toString(),
      'start_date': formattedStartDate,
      'apikey': '16a234026f7f4dc297d941f0a7b75862',
      if (formattedEndDate != null) 'end_date': formattedEndDate,
    });

    var quoteUrl = Uri.https('api.twelvedata.com', '/quote', {
      'symbol': symbol,
      'apikey': '16a234026f7f4dc297d941f0a7b75862',
    });

    var timeSeriesResponse = await http.get(timeSeriesUrl);
    var quoteResponse = await http.get(quoteUrl);

    if (timeSeriesResponse.statusCode == 200 &&
        quoteResponse.statusCode == 200) {
      var timeSeriesJson = jsonDecode(timeSeriesResponse.body);
      var quoteJson = jsonDecode(quoteResponse.body);

      interval = timeSeriesJson['meta']['interval'];
      currency = timeSeriesJson['meta']['currency'];
      exchange = timeSeriesJson['meta']['exchange'];

      // Convert the existing values to a map
      var valuesMap = {for (var value in values) value.dateTime: value};

      // Merge the new data with the existing data
      for (var data in timeSeriesJson['values']) {
        var value = StockValue.fromJson(data);
        valuesMap.putIfAbsent(value.dateTime, () => value);
      }

      // Convert the map back to a list
      values = valuesMap.values.toList();

      // Store quote data
      name = quoteJson['name'];
      quote = Quote.fromJson(quoteJson);

      logoUrl = await fetchLogo();
    } else {
      print(
          'Request failed with status: ${timeSeriesResponse.statusCode} and ${quoteResponse.statusCode}.');
    }
  }

  Future<String> fetchLogo() async {
    var url = Uri.parse(
        'https://api.twelvedata.com/logo?symbol=$symbol&apikey=16a234026f7f4dc297d941f0a7b75862');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['url'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return '';
    }
  }

  List<Map<String, String>> getLastXDaysData(int days) {
    var now = DateTime.now();
    var xDaysAgo = now.subtract(Duration(days: days));

    return values
        .where((value) => DateTime.parse(value.dateTime).isAfter(xDaysAgo))
        .map((value) => {'dateTime': value.dateTime, 'close': value.close})
        .toList();
  }

  bool isMarketOpen() {
    return quote.isMarketOpen;
  }

  bool isCloseDifferencePositive() {
    return double.parse(quote.change) > 0;
  }

  String getFormattedChange() {
    return "${quote.change.substring(0, 0)}${double.parse(quote.change).toStringAsFixed(2)}";
  }

  String getFormattedPercentageChange() {
    return "(${quote.percentChange.substring(0, 0)}${double.parse(quote.percentChange).toStringAsFixed(2)}%)";
  }


}

class StockValue {
  final String dateTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;
  final String? previousClose;

  StockValue({
    required this.dateTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.previousClose,
  });

  factory StockValue.fromJson(Map<String, dynamic> json) {
    return StockValue(
      dateTime: json['datetime'],
      open: json['open'],
      high: json['high'],
      low: json['low'],
      close: json['close'],
      volume: json['volume'],
      previousClose: json['previous_close'],
    );
  }
}

class Quote {
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;
  final String previousClose;
  final String change;
  final String percentChange;
  final bool isMarketOpen;

  Quote({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.previousClose,
    required this.change,
    required this.percentChange,
    required this.isMarketOpen,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      open: json['open'],
      high: json['high'],
      low: json['low'],
      close: json['close'],
      volume: json['volume'],
      previousClose: json['previous_close'],
      change: json['change'],
      percentChange: json['percent_change'],
      isMarketOpen: json['is_market_open'],
    );
  }
}
