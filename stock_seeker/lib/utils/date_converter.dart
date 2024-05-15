import 'package:intl/intl.dart';

// Function to convert a date to any pattern
String convertDate(String date, String pattern) {
  var parsedDate = DateTime.parse(date);
  var formatter = DateFormat(pattern);
  return formatter.format(parsedDate);
}