import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/pay_bill.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillsPage extends StatefulWidget { 
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> with RouteAware {
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  void _refreshBills() async {
    final data = await SQLHelper.getBills();    
    setState(() {
      final modifiableData = List<Map<String, dynamic>>.from(data).where((item)=> item['isallPaid']==0).toList();
      modifiableData.sort((a, b) => a['duedatetime'].compareTo(b['duedatetime']));
      _bills = modifiableData;
      _isLoading = false;
    });
  }
  
  @override
  void didPopNext() {
    _refreshBills();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
 
  @override
  void initState() {
    super.initState();
    _refreshBills();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Manager'),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, size: 25,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
            
            child: ListView.builder(    
            itemCount:  _bills.isNotEmpty? _bills.length +1 : 2 ,
            itemBuilder: (context, index){
              if(index == 0){
               return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Padding(
                     padding: const EdgeInsets.all(10.0),
                     child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                       children: [
                         Text("Upcoming Bills", style: Theme.of(context).textTheme.titleMedium,),
                         Text("Click to Pay", style: Theme.of(context).textTheme.titleSmall,),                         
                       ],
                     ),
                   ),
                  
                 ],
               );
              }
              index -=1;
              return _bills.isEmpty ? Center(child:Column(
                children: [
                  const Text('No Bills Recorded Yet!'),
                  const Text('Add bills from the Add Button in Dashboard')
                ],
              )) :
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return PayBill(parentBillID: _bills[index]['id'], duedatetime: _bills[index]['duedatetime'], txnfrequency:  _bills[index]['frequency'] as double, parentBillName: _bills[index]['billname'], );
                      }));
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Colors.black54                    
                      ),
                      borderRadius: BorderRadiusGeometry.circular(10)
                        
                  ),        
                  leading:  Icon(Icons.monetization_on_outlined, size: 32, color:Colors.redAccent),
                  title: Text(_bills[index]['billname'] ?? 'No Name', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Due: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_bills[index]['duedatetime'])).toString()}'),
                  // trailing: Text('${_bills[index]['curbillamt']}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
            }
           ),
          ),
    );
  }
}
