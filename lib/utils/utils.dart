import 'package:intl/intl.dart';



int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
var currentMonth = int.parse(DateFormat('MM').format(kToday));
var currentYear = int.parse(DateFormat('yyyy').format(kToday));
var kFirstDay = DateTime(currentYear, currentMonth, 1);
var kLastDay = DateTime(currentYear, currentMonth +1, 0);
