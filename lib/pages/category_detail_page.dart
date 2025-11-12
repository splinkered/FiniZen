import 'dart:convert';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/pages/bill_transaction_detail_page.dart';
import 'package:FiniZen/pages/record_detail_page.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class CategoryDetailPage extends StatefulWidget {
  final int id;
  const CategoryDetailPage({super.key,required this.id});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> with RouteAware{
  final GlobalKey<FormBuilderState> _formKey3 = GlobalKey<FormBuilderState>();
  final  GlobalKey<FormBuilderState> _formKey4 = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _journal = {};
  List<Map<String, dynamic>> _categorytransactions = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  void _refreshJournal() async {
    final data = await SQLHelper.getcategoryatID(widget.id);
    final cdata = await SQLHelper.getallcategories();
    String jsonString = data.first['iddata'] as String;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<int> datalist = List<int>.from(jsonList);    
    
    


    final data2 =  data[0]['isReceived']==3? await SQLHelper.getbillTransactionRecords() : await SQLHelper.getRecordsatIds(datalist);
    setState(() {
      _journal = data[0];
      _categorytransactions = data2;
      _isLoading = false;
      if(_journal['isReceived'] == 1){
        _categories = cdata.where((item)=> ((item['isReceived'] == 1 || item['isReceived'] == 2) && (item['id'] != _journal['id']) && (item['name']!= "Savings"))).toList();
      } else if(_journal['isReceived'] ==0) {
        _categories = cdata.where((item)=> ((item['isReceived'] == 0 || item['isReceived'] == 2) && (item['id'] != _journal['id']) && (item['name']!= "Savings"))).toList();      
      }
      });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();    
    routeObserver.subscribe(this, ModalRoute.of(context)!);     
  }

  @override
  void didPopNext() {
   setState(() {
    _refreshJournal();
    });
  }
  

  @override
  void initState() {
    super.initState();
    _refreshJournal();
  }


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
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
                      Text("Edit Category", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 10,),
                      FormBuilderTextField(
                        name: 'categoryname',
                        initialValue: _journal['name'].toString(),
                        decoration: const InputDecoration(labelText: 'Enter Name', prefixIcon: Icon(Icons.currency_rupee),),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(20)
                        ]),
                      ),
                              
                      const SizedBox(height: 10),
                              
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text("Details", style: Theme.of(context).textTheme.titleMedium,),
                          
                            FormBuilderTextField(
                              name: 'categorydetails',
                              initialValue: _journal['notes'] ?? '',
                              decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline),),
                              validator: FormBuilderValidators.compose([
                                
                              ]),
                            ),
                                        
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text("For Income?", style: Theme.of(context).textTheme.titleMedium,),
                            FormBuilderCheckbox(
                              name: 'isReceived',
                              title: const Text('Is the category used to track income?', style: TextStyle(fontSize: 20),),
                              initialValue: (_journal['isReceived']==1) ? true : false,
                              onChanged: (bool? value) {},
                              activeColor: Colors.deepPurpleAccent,
                            ),
                          ],
                        ),
                              
                              
                      const SizedBox(height: 10),
                              
                                                  
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed:() async {
                              final key =await _onSubmit();
                              if(key){
                                const added = SnackBar(content: Text('Category Edited Sucessfully'));
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
          itemCount: _categorytransactions.isNotEmpty? _categorytransactions.length +1 : 2,
          itemBuilder: (context, index){
            if(index == 0){
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: 
              
              Column(              
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  FinAppTopNavigationBar(greeting: 'Category Detail', titleGiven: 'All about a category!'),
                  _journal['isReceived']== 2 || _journal['isReceived']== 3 ? 
                  
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
                    ],
                  ) 
                      : Row(
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
                            title: Text('Delete Category', style: Theme.of(context).textTheme.titleMedium,),
                            content: FormBuilder(      
                              key: _formKey4,                        
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  Text('Move the transactions to which category?'),
                                  FormBuilderDropdown<int>(
                                  name: 'category',
                                  menuMaxHeight: 250,
                                  items: _categories
                                      .map<DropdownMenuItem<int>>(
                                        (item) => DropdownMenuItem<int>(
                                          value: item['id'] as int,
                                          child: Text(item['name'] as String),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (int? value) {
                                    debugPrint('Selected category id: $value');
                                  },
                                  initialValue: 1,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required()
                                  ]),
                                )
                                ],
                              )
                            ),
                            actions: [
                              TextButton(
                                //remove the dialog by popping it off the stack
                                onPressed: (){ Navigator.of(context).pop();}, 
                                child: const Text('Cancel', style: TextStyle(color: Colors.blue),),
                                
                              ),
                              TextButton(
                                onPressed: (){                                
                                  _onDelete();
                                  Navigator.of(context)..pop()..pop()..pop();
                                }, 
                                child: const Text('Delete', style: TextStyle(color: Colors.red),),
                                
                              )
                            ],
                          );
                        });
                      
                      
                        }, 
                        icon: const Icon(Icons.delete_forever, color: Colors.black87,),
                      ),                    
                    ],                  
                  ),
                  Row(
                    spacing: 10,
                    children: [                    
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category Name', style: Theme.of(context).textTheme.titleMedium,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1, color: Colors.black54                    
                                ),
                                borderRadius: BorderRadiusGeometry.circular(10)
                              ),
                              leading: Icon(Icons.info_outline  ),
                              title: Text('${_journal['name']}', style: Theme.of(context).textTheme.bodyMedium,),
                            )
                          ],
                        ),
                      ),
                     
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
                    title: Text( _journal['notes'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 10,),
                      
                  Row(
                    spacing: 10,
                    children: [       
                      _journal['isReceived']== 2  || _journal['isReceived']== 3 ?  SizedBox() :              
                      Expanded(

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Is For Money', style: Theme.of(context).textTheme.titleMedium,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1, color: Colors.black54                    
                                ),
                                borderRadius: BorderRadiusGeometry.circular(10)
                              ),
                              leading:  _journal['isReceived']==1? const Icon(Icons.call_received, color: Colors.green): const Icon(Icons.call_made, color: Colors.red,),
                              title: Text(_journal['isReceived']==1? "Received": "Given", style: Theme.of(context).textTheme.titleMedium,),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:30,),
                  
                  Text('Payment details', style: Theme.of(context).textTheme.titleMedium,),
                ],
              ),
            );
            }
            index -= 1;
            return _categorytransactions.isEmpty ? Center(child:Text('No Transactions Recorded Yet')) :
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    _journal['isReceived']==3? 
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return BillTransactionDetailPage(id:_categorytransactions[index]['id'] );
                      }))                    
                    : Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return RecordDetailPage(id:_categorytransactions[index]['id'] );
                      }));
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Colors.black54                    
                      ),
                      borderRadius: BorderRadiusGeometry.circular(10)
                        
                  ),        
                  leading:  Icon(Icons.monetization_on_outlined, size: 32, color:Colors.green),
                  title:  Text(  _journal['isReceived']==3? 
                      _categorytransactions[index]['notes'] ?? 'No Detail'
                    : _categorytransactions[index]['details'] ?? 'No Detail', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Paid on: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_categorytransactions[index]['txndatetime'])).toString()}'),
                  trailing: Text('$currentcurrency ${_categorytransactions[index]['amt']}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
          }
        ),
      ),
    );

  }

  Future<bool> _onSubmit()  async {
    
    if (!_formKey3.currentState!.saveAndValidate()) return false;
    
    await SQLHelper.updatecategory(
      widget.id,
      _formKey3.currentState!.value['categoryname'].toString(),
      _formKey3.currentState!.value['categorydetails'].toString(),  
      _journal['iddata'],
      _formKey3.currentState!.value['isReceived']? 1:0,

    );
    return true;



  }
  
  void _onDelete() async{
    if (!_formKey4.currentState!.saveAndValidate()) return;
    final int newCategoryId = _formKey4.currentState!.value['category'];
    List<int> idList = List<int>.from(jsonDecode(_journal['iddata']));
    await SQLHelper.addCategorydata(newCategoryId, idList);
    await SQLHelper.deletecategory(widget.id, newCategoryId);
  }
  
}