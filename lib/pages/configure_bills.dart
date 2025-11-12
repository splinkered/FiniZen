import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/bill_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfigureBills extends StatefulWidget {
  const ConfigureBills({super.key});

  @override
  State<ConfigureBills> createState() => _ConfigureBillsState();
}

class _ConfigureBillsState extends State<ConfigureBills> {
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  void _refreshBills() async {
    final data = await SQLHelper.getBills();
    setState(() {            
      _bills = data;
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _refreshBills();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      
        appBar: AppBar(
        toolbarHeight: 60,
        //backgroundColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15)
          )            
        ),
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Configure Bills", style: Theme.of(context).textTheme.titleMedium ),
            IconButton(onPressed: (){
              _refreshBills();
            }, icon: Icon(Icons.refresh))
          ],
        ),
        leading: ModalRoute.of(context)?.canPop == true? IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 25,
            ),onPressed: () {
             Navigator.of(context).pop();
            }) : null,
            
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
                    child: Row(
                    spacing: 5,
                    children: [
                      Text('All Bills', style: Theme.of(context).textTheme.titleMedium,)                   
                    ]
                                
                                    ),
                  ),
                 ],
               );
              }
              index -=1;
              return _bills.isEmpty ? Center(child:Column(
                children: [
                  Text('No Bills Recorded Yet'),
                  const Text('Add bills from the Add Button in Dashboard')
                ],
              )) :
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return BillDetailPage(id: _bills[index]['id'],);
                      }));
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Colors.black54                    
                      ),
                      borderRadius: BorderRadiusGeometry.circular(10)
                        
                  ),        
                  leading:  Icon(Icons.monetization_on_outlined, size: 32, color:Colors.black87),
                  title: Text(_bills[index]['billname']!=null ? _bills[index]['billname']! : '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_bills[index]['duedatetime'])).toString()),
                  //trailing: Text('${_bills[index]['curbillamt']!= -1 ? _bills[index]['curbillamt']: ''}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
            }
                          ),
          ),
      ),
    );
  }
}