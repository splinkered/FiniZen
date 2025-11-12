import 'dart:convert';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/pages/bill_transaction_detail_page.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class BillDetailPage extends StatefulWidget {
  final int id;
  
  const BillDetailPage({super.key,required this.id});

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  final GlobalKey<FormBuilderState> _formKey3 = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _journal = {};
  List<Map<String, dynamic>> _billtransactions = [];
  
  bool _isLoading = true;
  void _refreshJournal() async {
    final data = await SQLHelper.getBill(widget.id);

    String jsonString = data.first['data'] as String;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<int> datalist = List<int>.from(jsonList);

    final data2 = await SQLHelper.getbillTransactionRecordsatIds(datalist);
    setState(() {
      _journal = data[0];
      _billtransactions = data2;
      _isLoading = false;
    });
  }
  

  @override
  void initState() {
    super.initState();
    _refreshJournal(); // Loading the diary when the app starts
  }


  @override
  void dispose() {
    super.dispose();
  } 
  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteBill(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Record!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
   
      void _showForm(int? id) async {
       
        showModalBottomSheet(
            context: context,
            elevation: 5,
            isScrollControlled: true,
            builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 90,
              ),
              child: SizedBox(
                height: 461,
                child: SingleChildScrollView(
                  child: FormBuilder(
                  key: _formKey3,
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      const SizedBox(height: 10,),
                      Text("Edit Bill", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 10,),
                      FormBuilderTextField(
                        name: 'billname',
                        initialValue: _journal['billname'].toString(),
                        decoration: const InputDecoration(labelText: 'Enter Name', prefixIcon: Icon(Icons.info_outline),),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                              
                      const SizedBox(height: 10),
                              
                        Row(                        
                        spacing: 10,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text("Bill Details", style: Theme.of(context).textTheme.titleMedium,),
                              
                                FormBuilderTextField(
                                  name: 'billdetails',
                                  initialValue: _journal['billname'].toString(),
                                  decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline),),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                ),
                  
                              ],
                            )
                          ),
                              
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text("Current Due Date", style: Theme.of(context).textTheme.titleMedium,),
                              
                                FormBuilderDateTimePicker(                                  
                                  name: 'duedatetime',                                                              
                                  inputType: InputType.date,                                  
                                  initialDate: DateTime.parse(_journal['duedatetime']),
                                  initialValue: DateTime.parse(_journal['duedatetime']),
                                  firstDate: DateTime(1900),
                                  onChanged: (DateTime? value) {},
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.dateTime()
                                  ]),
                                  
                                  
                                ),
                                
                  
                              ],
                            )
                          ),
                        ],
                      ),
                              
                              
                      const SizedBox(height: 10),
                              
                      Text("Frequency", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 4,),            
                      FormBuilderSlider(
                        name: 'frequency',                                  
                        min: 0,
                        max: 12,
                        divisions: 24,
                        initialValue:_journal['frequency'],
                        onChanged: (double? value) {},
                      ),
                    
                              
                      const SizedBox(height: 10,),                    
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed:() async {
                              final key =await _onSubmit();
                              if(key){
                                const added = SnackBar(content: Text('Bill Edited Sucessfully'));
                                ScaffoldMessenger.of(context).showSnackBar(added);                                
                                Navigator.of(context).pop();
                                _refreshJournal();
                              }
                              
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(175, 50)
                            ),
                            child: const Text(
                              'Submit', 
                              style: TextStyle(
                                color: Colors.black87, 
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                
                              ),
                            ),                  
                          ),                          
                        ],
                      ),
                      const SizedBox(height: 25,)
                    ],
                  ),
                              ),
                ),
              )
            ));
      }

    return _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          :SafeArea(
      child: Scaffold(      
      
      
        body: ListView.builder(
          itemCount: _billtransactions.isNotEmpty? _billtransactions.length +1 : 2,
          itemBuilder: (context, index){
            if(index == 0){
            return Column(
              children: [
                FinAppTopNavigationBar(greeting: 'Bill Details', titleGiven: 'Manage/edit Bill'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [             
                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton.filled(
                            onPressed: (){
                              setState(() {
                                _refreshJournal();
                              });
                            }, 
                            icon: const Icon(Icons.refresh, color: Colors.black87,),
                          ),
                          IconButton.filled(
                            onPressed: (){
                              _showForm(widget.id);
                            }, 
                            icon: const Icon(Icons.edit, color: Colors.black87,),
                          ),
                          IconButton.filled(
                            onPressed: (){
                          
                              showDialog(
                          //not allow to exit if pressed outside dialog
                          barrierDismissible: false,
                          context: context,
                          builder: (context){
                          
                              return AlertDialog(                  
                                title: Text('Delete Record', style: Theme.of(context).textTheme.titleMedium,),
                                content: const Text('Are you sure you want to remove the Record?'),
                                actions: [
                                  TextButton(
                                    //remove the dialog by popping it off the stack
                                    onPressed: (){ Navigator.of(context).pop();}, 
                                    child: const Text('No', style: TextStyle(color: Colors.blue),),
                                    
                                  ),
                                  TextButton(
                                    onPressed: () async{
                                    
                                        _deleteItem(widget.id);
                                      Navigator.of(context)..pop()..pop()..pop();
                                    }, 
                                    child: const Text('Yes', style: TextStyle(color: Colors.red),),
                                    
                                  )
                                ],
                              );
                            });
                          
                          
                            }, 
                            icon: const Icon(Icons.delete_forever, color: Colors.black87,),
                          ),                    
                        ],                  
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bill Name', style: Theme.of(context).textTheme.titleMedium,),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1, color: Colors.black54                    
                              ),
                              borderRadius: BorderRadiusGeometry.circular(10)
                            ),
                            leading: Icon(Icons.info_outline  ),
                            title: Text('${_journal['billname']}', style: Theme.of(context).textTheme.titleMedium,),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Frequency', style: Theme.of(context).textTheme.titleMedium,),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1, color: Colors.black54                    
                              ),
                              borderRadius: BorderRadiusGeometry.circular(10)
                            ),
                            leading: const Icon(Icons.timer_outlined),
                            title: Text('${_journal['frequency']} months', style: Theme.of(context).textTheme.titleMedium,),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Text('Details', style: Theme.of(context).textTheme.titleMedium,),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1, color: Colors.black54                    
                          ),
                          borderRadius: BorderRadiusGeometry.circular(10)
                        ),
                        leading: const Icon(Icons.info_outline),
                        title: Text( _journal['billdetails'] ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          
                        ),overflow: TextOverflow.clip,),
                      ),
                      const SizedBox(height: 10,),
                          
                      Row(
                        spacing: 10,
                        children: [                    
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upcoming Due Date', style: Theme.of(context).textTheme.titleMedium,),
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1, color: Colors.black54                    
                                    ),
                                    borderRadius: BorderRadiusGeometry.circular(10)
                                  ),
                                  leading: const Icon(Icons.calendar_month),
                                  title: Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_journal['duedatetime'])).toString(), style: Theme.of(context).textTheme.titleMedium,),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height:30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [ 
                          FilledButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(150,50)
                            ), 
                            child: const Text('Back', style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),),
                          )
                        ],
                      ),
                      const SizedBox(height:10,),
                      Text('Payment details', style: Theme.of(context).textTheme.titleMedium,),
                    ],
                  ),
                ),
              ],
            );
            }
            index -= 1;
            return _billtransactions.isEmpty ? Center(child:Text('No Transactions Recorded Yet')) :
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return BillTransactionDetailPage(id: widget.id);
                      }));
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Colors.black54                    
                      ),
                      borderRadius: BorderRadiusGeometry.circular(10)
                        
                  ),        
                  leading:  Icon(Icons.monetization_on_outlined, size: 32, color:Colors.green),
                  title: Text(_journal['billname']!=null ? _journal['billname']! : '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Paid on: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_billtransactions[index]['duedatetime'])).toString()}'),
                  trailing: Text('$currentcurrency ${_billtransactions[index]['amt'].toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
          }
        ),
      ),
    );

  }

  Future<bool> _onSubmit()  async {
    
    if (!_formKey3.currentState!.saveAndValidate()) return false;
    
    await SQLHelper.updateBill(
      widget.id,
      _journal['curbillamt'], 
      _formKey3.currentState!.value['billname'].toString(),
      _formKey3.currentState!.value['billdetails'].toString(),      
      _formKey3.currentState!.value['frequency'],
      _formKey3.currentState!.value['duedatetime'].toString(),
      _journal['data'],
      0
    );
    return true;



  }
  
}