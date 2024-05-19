import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final List<String> apiKeys = [
  '16a234026f7f4dc297d941f0a7b75862',
  '380cf148d7b34ce5af5d47c82234817f',
  '952b25154aad4d27977bd5b8733502c4',
  '27e5935b356445c3b135e2e641281b2f',
  '55e73396144f4b4cacb85a640a4e0a4c',
];

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
      return asc
          ? aPercentChange.compareTo(bPercentChange)
          : bPercentChange.compareTo(aPercentChange);
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
  late List<StockValue> history = [];
  late List<StockValue> daily = [];
  late Quote quote;
  late String logoUrl;

  Stock({required this.symbol});

  Future<void> fetchData(
      {required String symbol, String timezone = 'Europe/Lisbon'}) async {
    await fetchHistoryData(symbol: symbol, timezone: timezone);

    await fecthQuoteData(symbol: symbol);

    if (quote.isMarketOpen) {
      // Define the start date as today
      var now = DateTime.now();
      var dateFormatter = DateFormat('yyyy-MM-dd');
      var formattedNow = dateFormatter.format(now);

      await fetchDailyData(
          symbol: symbol, startDate: formattedNow, timezone: timezone);
    } else {
      // Define the start date as yesterday
      var yesterday = DateTime.now().subtract(const Duration(days: 1));
      var dateFormatter = DateFormat('yyyy-MM-dd');
      var formattedYesterday = dateFormatter.format(yesterday);

      await fetchDailyData(
          symbol: symbol, startDate: formattedYesterday, timezone: timezone);
    }

    await fetchLogo();
  }

  Future<void> fetchDailyData({
    required String symbol,
    String interval = '5min',
    int outputSize = 1440,
    int dp = 2,
    String order = 'ASC',
    bool previousClose = true,
    String? startDate,
    String? endDate,
    timezone = 'Europe/Lisbon',
    int apiKeyIndex = 0, // Index of the API key to start with
  }) async {
    var url = Uri.https('api.twelvedata.com', '/time_series', {
      'symbol': symbol,
      'interval': interval,
      'outputsize': outputSize.toString(),
      'timezone': timezone,
      'order': order,
      'dp': dp.toString(),
      'previous_close': previousClose.toString(),
      'apikey': apiKeys[apiKeyIndex], // Use the current API key
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });

    var response = await http.get(url);
    var json = jsonDecode(response.body);

    try {
      daily = (json['values'] as List)
          .map((value) => StockValue.fromJson(value))
          .toList();
    } catch (e) {
      if (json['code'] == 429) {
        // If rate limited and there are more API keys, try the next API key
        await fetchDailyData(
          symbol: symbol,
          interval: interval,
          outputSize: outputSize,
          dp: dp,
          order: order,
          previousClose: previousClose,
          startDate: startDate,
          endDate: endDate,
          timezone: timezone,
          apiKeyIndex: apiKeyIndex < apiKeys.length - 1
              ? apiKeyIndex + 1
              : 0, // Try the next API key
        );
      } else {
        print('Request failed with status: $e.');
      }
    }
  }

  Future<void> fecthQuoteData(
      {required String symbol, int apiKeyIndex = 0, int dp = 2}) async {
    var url = Uri.https('api.twelvedata.com', '/quote', {
      'symbol': symbol,
      'dp': dp.toString(),
      'apikey': apiKeys[apiKeyIndex],
    });

    var response = await http.get(url);
    var json = jsonDecode(response.body);

    try {
      name = json['name'];
      quote = Quote.fromJson(json);
    } catch (e) {
      print(e);
      if (json['code'] == 429) {
        await fecthQuoteData(
          symbol: symbol,
          apiKeyIndex: apiKeyIndex < apiKeys.length - 1
              ? apiKeyIndex + 1
              : 0, // Try the next API key
        );
      } else {
        print('Request failed with status: $e.');
      }
    }
  }

  Future<void> fetchHistoryData(
      {required String symbol,
      String interval = '1day',
      int outputSize = 180, // Default to previous 6 months
      int dp = 2,
      String order = 'ASC',
      bool previousClose = true,
      String? startDate,
      String? endDate,
      timezone = 'Europe/Lisbon',
      int apiKeyIndex = 0}) async {
    var url = Uri.https('api.twelvedata.com', '/time_series', {
      'symbol': symbol,
      'interval': interval,
      'outputsize': outputSize.toString(),
      'dp': dp.toString(),
      'order': order,
      'previous_close': previousClose.toString(),
      'timezone': timezone,
      'apikey': apiKeys[apiKeyIndex],
      if (endDate != null) 'end_date': endDate,
      if (startDate != null) 'start_date': startDate,
    });

    var response = await http.get(url);
    var json = jsonDecode(response.body);

    try {
      interval = json['meta']['interval'];
      currency = json['meta']['currency'];
      exchange = json['meta']['exchange'];

      history = (json['values'] as List)
          .map((data) => StockValue.fromJson(data))
          .toList();

      print('History data fetched for $symbol');
    } catch (e) {
      print("$symbol   $e");
      // If rate limited and there are more API keys, try the next API key
      if (json['code'] == 429) {
        await fetchHistoryData(
          symbol: symbol,
          interval: interval,
          outputSize: outputSize,
          dp: dp,
          order: order,
          previousClose: previousClose,
          startDate: startDate,
          endDate: endDate,
          timezone: timezone,
          apiKeyIndex: apiKeyIndex < apiKeys.length - 1
              ? apiKeyIndex + 1
              : 0, // Try the next API key
        );
      } else {
        print('Request failed with status: $e.');
      }
    }
  }

  Future<void> fetchLogo({int apiKeyIndex = 0}) async {
    var url = Uri.parse(
        'https://api.twelvedata.com/logo?symbol=$symbol&apikey=${apiKeys[apiKeyIndex]}');

    var response = await http.get(url);
    var json = jsonDecode(response.body);

    try {
      logoUrl = json['url'];
    } catch (e) {
      if (json['code'] == 429) {
        await fetchLogo(
            apiKeyIndex: apiKeyIndex < apiKeys.length - 1
                ? apiKeyIndex + 1
                : 0); // Try the next API key
      } else {
        print('Request failed with status: $e.');
      }
    }
  }

  List<Map<String, String>> getLastXDaysData(int days) {
    var now = DateTime.now();
    var xDaysAgo = now.subtract(Duration(days: days));

    return history
        .where((value) => DateTime.parse(value.dateTime).isAfter(xDaysAgo))
        .map((value) => {'dateTime': value.dateTime, 'close': value.close})
        .toList();
  }

  bool isMarketOpen() {
    return quote.isMarketOpen;
  }

  bool isQuoteCloseDifferencePositive() {
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
