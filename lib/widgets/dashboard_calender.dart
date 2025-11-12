import 'dart:collection';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/models/TransactionEvent.dart';
import 'package:FiniZen/pages/bill_transaction_detail_page.dart';
import 'package:FiniZen/pages/record_detail_page.dart';
import 'package:FiniZen/providers/dashboarddbprovider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:FiniZen/utils/utils.dart';

class DashboardCalender extends StatefulWidget {
  const DashboardCalender({super.key});

  @override
  State<DashboardCalender> createState() => _DashboardCalender();
}



class _DashboardCalender extends State<DashboardCalender> {
  late final ValueNotifier<List<Transactionevent>> _selectedEvents;
  ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  



  //late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;


  LinkedHashMap<DateTime, List<Transactionevent>>? kEvents;

  Map<DateTime, List<Transactionevent>>? _kEventSource;

  List<Map<String, dynamic>> categories= [];

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final recordItems = Provider.of<RecordsProvider>(context).records;

  // Clear and rebuild the event source
  final newEventSource = <DateTime, List<Transactionevent>>{};

  // Load AllTransactionRecords
  for (var item in recordItems) {
    DateTime fullDateTime = DateTime.parse(item['txndatetime']);
    DateTime dateOnly = DateTime(fullDateTime.year, fullDateTime.month, fullDateTime.day);

    final event = Transactionevent(
      item['isReceived'],
      item['id'],
      item['details'] ?? 'No Details',
      item['amt'],
      item['txndatetime'],
      false,
    );

    newEventSource.putIfAbsent(dateOnly, () => []).add(event);
  }

  // Now load BillTransactionRecords and add to same event source
  SQLHelper.getbillTransactionRecords().then((bills) {
    for (var bill in bills) {
      DateTime fullDateTime = DateTime.parse(bill['txndatetime']);
      DateTime dateOnly = DateTime(fullDateTime.year, fullDateTime.month, fullDateTime.day);

      final event = Transactionevent(
        -1,
        bill['id'],
        bill['billname'] ?? 'Bill Payment',
        bill['amt'],
        bill['txndatetime'],
        true,
      );

      newEventSource.putIfAbsent(dateOnly, () => []).add(event);
    }

    if (mounted) {
      setState(() {
        _kEventSource = newEventSource;
        kEvents = LinkedHashMap<DateTime, List<Transactionevent>>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_kEventSource!);

        // Rebuild selectedEvents if needed
        _selectedEvents.value = _getEventsForDays(_selectedDays);
      });
    }
  });
}


  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    loadCategories();
  }

  @override
  void dispose() {
    ///_pageController.dispose();
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Transactionevent> _getEventsForDay(DateTime day) {
    return kEvents?[day] ?? [];
  }

  List<Transactionevent> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Transactionevent> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void loadCategories() async{
    categories = await SQLHelper.getallcategories();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                clearButtonVisible: canClearSelection,
                
                onClearButtonTap: () {
                  setState(() {
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedDays.clear();
                    _selectedEvents.value = [];
                  });
                },
                onLeftArrowTap: () {
  if (currentMonth != 1) {
    currentMonth -= 1;
  } else {
    currentMonth = 12;
    currentYear -= 1;
  }

  setState(() {
    final newFocused = DateTime(currentYear, currentMonth, 1);
    _focusedDay.value = newFocused;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedDays.clear();
    _selectedEvents.value = [];
    kFirstDay = DateTime(currentYear, currentMonth, 1);
    kLastDay = DateTime(currentYear, currentMonth + 1, 0);
  });
},

onRightArrowTap: () {
  if (currentMonth != 12) {
    currentMonth += 1;
  } else {
    currentMonth = 1;
    currentYear += 1;
  }

  setState(() {
    final newFocused = DateTime(currentYear, currentMonth, 1);
    _focusedDay.value = newFocused;
    _rangeStart = null;
    _rangeEnd = null;
    _selectedDays.clear();
    _selectedEvents.value = [];
    kFirstDay = DateTime(currentYear, currentMonth, 1);
    kLastDay = DateTime(currentYear, currentMonth + 1, 0);
  });
},
              );
            },
          ),
          TableCalendar<Transactionevent>(
            daysOfWeekHeight: 35,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay.value,
            headerVisible: false,
            selectedDayPredicate: (day) => _selectedDays.contains(day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,            
            // holidayPredicate: (day) {
            //   // Every 20th day of the month will be treated as a holiday
            //   return day.day == 20;
            // },
            onDaySelected: _onDaySelected,
            availableGestures: AvailableGestures.none,
            onRangeSelected: _onRangeSelected,
            //onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(day.toString()),
              );              
            },
            
            markerBuilder: (context, day, event) { 
              final numtoput = event.length >=10 ? '9+' : event.length;
              return event.isNotEmpty ? Row(
                children: [
                  const Spacer(),
                  Container(
                        width: 24,
                        height: 25,
                        
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                        ),
                        child: Center(
                          child: Text(
                            '$numtoput',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                ],
              ): null;
              },
              
          ),
          
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<List<Transactionevent>>(
          valueListenable: _selectedEvents,
          builder: (context, value, _) {
            return ListView.builder(
              itemCount: value.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black54, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ), 
                      leading: value[index].isMoneyReceived==1 ? const Icon(Icons.call_received, color:Colors.green): const Icon(Icons.call_made, color:Colors.red),
                      onTap: () {
                       // setState(() {
                          _rangeStart = null;
                          _rangeEnd = null;
                          _selectedDays.clear();
                          _selectedEvents.value = [];
                        //});
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          if (value[index].isBill) {
                            return BillTransactionDetailPage(id: value[index].id, ); // <-- Your bill detail page
                          } else {
                            return RecordDetailPage(id: value[index].id);
                          }
                        }));
                      },
                      title: Text(value[index].details, style: Theme.of(context).textTheme.titleMedium,),
                      subtitle: Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(value[index].time)).toString()),
                      trailing: Text('$currentcurrency ${value[index].amt.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  );
                },                  
              );
            },
          ),
        ],
      );
  }

}



class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          
          if (clearButtonVisible)
            IconButton(
              icon: const Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
