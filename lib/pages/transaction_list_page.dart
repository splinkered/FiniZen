import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/record_detail_page.dart';
import 'package:FiniZen/providers/dashboarddbprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:provider/provider.dart';

class TransactionListPage extends StatefulWidget {
  final bool? isReceivedfilter;
  const TransactionListPage({super.key, this.isReceivedfilter});

  @override
  State<TransactionListPage> createState() => _TransactionListPage();
}

class _TransactionListPage extends State<TransactionListPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  bool showClearFilterButton = false;

  // All journals
  List<Map<String, dynamic>> _journals = [];
  DateRange? _selectedRange;

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    Provider.of<RecordsProvider>(context, listen: false).freshRecords();
    
    List<Map<String, dynamic>> data;
  
      if (_selectedRange != null) {
        DateTime startOfDay = DateTime(
        _selectedRange!.start.year,
        _selectedRange!.start.month,
        _selectedRange!.start.day,
        0, 0, 0,
      );
      DateTime endOfDay = DateTime(
        _selectedRange!.end.year,
        _selectedRange!.end.month,
        _selectedRange!.end.day,
        23, 59, 59,
      );
      data = await SQLHelper.getRecordsBetweenDates(startOfDay, endOfDay);
    } else {
      data = Provider.of<RecordsProvider>(context, listen: false).records;
    }
    setState(() {
      if(widget.isReceivedfilter == true){
        _journals = data.where((item) => item['isReceived']==1).toList();
      }else if(widget.isReceivedfilter == false){
        _journals = data.where((item) => item['isReceived']==0).toList();
      } else{
        _journals = data;
      }
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); 
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, size: 25,),
          onPressed: () => Navigator.of(context)..pop()..pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
            itemCount: _journals.isNotEmpty? _journals.length +1 : 2 ,
            itemBuilder: (context, index) {
                if (index == 0) {
                // return the header
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FormBuilder(
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           OutlinedButton(onPressed: (){
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                  ),
                                  child: SafeArea(
                                    top: false,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Select Your Range", style: Theme.of(context).textTheme.titleLarge),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 400,
                                              child: datePickerBuilder(context, (value) {
                                                
                                              }),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FilledButton(
                                              onPressed: () {
                                                _refreshJournals(); 
                                                Navigator.of(context).pop();                                           
                                              },
                                              child: Text("Select", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Cancel
                                              },
                                              child: Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                                                    }, 
                            
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(100, 60),
                              splashFactory: null,                                                    
                            ),
                            child: Text("Get in Range", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold ),),
                            
                            ),
                            if(showClearFilterButton)
                            IconButton(onPressed: (){
                              _selectedRange = null;
                              _refreshJournals();
                            }, icon: Icon(Icons.cancel_outlined, size: 40,))
                          
                          ],
                        ),
                        if(_selectedRange != null)
                        Center(
                          child: Text('From: ${_selectedRange!.start.day}/${_selectedRange!.start.month}/${_selectedRange!.start.year} To: ${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}')
                        )
                      ],
                    ),
                  ),
                );
              }
            index -= 1;
          return _journals.isEmpty ? Center(child:Text('No Transactions Recorded Yet')) :Card(
          color: Colors.white,
          // margin: const EdgeInsets.all(15),

          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return RecordDetailPage(id: _journals[index]['id'],);
              }));
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                  width: 1, color: Colors.black54                    
                ),
                borderRadius: BorderRadiusGeometry.circular(10)
                  
            ),        
            leading: _journals[index]['isReceived']==1? Icon(Icons.call_received, size: 32, color:Colors.green) : Icon(Icons.arrow_outward, size: 32, color:Colors.red) ,
            title: Text(_journals[index]['details']!=null ? _journals[index]['details']! : 'No Details', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_journals[index]['txndatetime'])).toString()),
            trailing: Text(_journals[index]['amt'].toStringAsFixed(2), style: Theme.of(context).textTheme.bodyLarge,),
          ),
       
                  );
                  }
                ),
     
    );
  }
 Widget datePickerBuilder (BuildContext context, dynamic Function(DateRange) onDateRangeChanged){
  final noww = DateTime.now();
  return DateRangePickerWidget(
    doubleMonth: false,
    //maximumDateRangeLength: 10,
    maxDate: DateTime(noww.year, noww.month, noww.day, 23, 59, 59),
    minimumDateRangeLength: 1,
    initialDateRange: _selectedRange != null ? _selectedRange! : DateRange( noww,  noww),
    //disabledDates: [DateTime(2023, 11, 20)],
    initialDisplayedDate:    DateTime.now(),
    onDateRangeChanged: (range) {
      setState(() {
        showClearFilterButton = true;
        _selectedRange = range;
      });
    },
);
 }

}