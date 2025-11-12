import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/add_to_savings_form_page.dart';
import 'package:FiniZen/pages/bill_transaction_detail_page.dart';
import 'package:FiniZen/pages/record_detail_page.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:FiniZen/widgets/goal_progress_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPage();
}

class _SavingsPage extends State<SavingsPage> with RouteAware {

  void _showSetGoalModal() {
    final _goalFormKey = GlobalKey<FormBuilderState>();
    final currentGoal = goalAmt; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: FormBuilder(
            key: _goalFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set Savings Goal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'goalAmt',
                  initialValue: currentGoal.toStringAsFixed(2),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Enter Goal Amount',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(0.01),
                  ]),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      if (_goalFormKey.currentState?.saveAndValidate() ?? false) {
                        final newGoal = double.tryParse(_goalFormKey.currentState!.value['goalAmt']) ?? 0;
                        await SQLHelper.updateGoalAmt(1, newGoal);
                        Navigator.of(context).pop();
                        _initsavings();
                        _refreshJournal();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Goal updated successfully')),
                        );
                      }
                    },
                    style: TextButton.styleFrom(minimumSize: const Size(175, 50)),
                    child: const Text(
                      'Update Goal',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }



  final GlobalKey<FormBuilderState> _formKey6 = GlobalKey<FormBuilderState>();
  Map<String, dynamic> goalTotals= {};
  double totalAmt = 0;
  double daPercent= 0;
  double goalAmt = 0;
  double leftAmt=0;
  
  void _initsavings() async {
    if (!mounted) return;
    final tmpTotal = await SQLHelper.getGoalTotals(); 
    final appdbList = await SQLHelper.getappData();
    double glAmt = appdbList.first['currentgoalamt'];
    setState(() {
      goalTotals = tmpTotal; 
      goalAmt = glAmt;
      totalAmt = goalTotals['spent']-goalTotals['received'];
      leftAmt = goalAmt-totalAmt;
      if(leftAmt < 0) leftAmt = 0;
      daPercent = (totalAmt/glAmt)*100;
      if(daPercent.isNegative || daPercent.isNaN){
        daPercent = 0;
      }
    });
    
  }
  Map<String, dynamic> _journal = {};
  List<Map<String, dynamic>> _categorytransactions = [];
  bool _isLoading = true;
  
  void _refreshJournal() async {
    final data = await SQLHelper.getcategoryatID(3);
    String jsonString = data.first['iddata'] as String;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<int> datalist = List<int>.from(jsonList);    
    
    


    final data2 =  data[0]['isReceived']==3? await SQLHelper.getbillTransactionRecords() : await SQLHelper.getRecordsatIds(datalist);
    setState(() {
      _journal = data[0];
      _categorytransactions = data2.reversed.toList();
      _isLoading = false;
      });
  }

  @override
  void initState() {    
    super.initState();
    _initsavings();
    _refreshJournal();
  }

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      
    }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  void didPopNext() {
   setState(() {
     _initsavings();
     _refreshJournal();
    });
  }

  

  @override
  Widget build(BuildContext context) {

    void _showForm() async {
       
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
                  key: _formKey6,
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      const SizedBox(height: 10,),
                      Text("Withdraw Savings", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 10,),
                      FormBuilderTextField(
                        name: 'Amount',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Enter Amount', prefixIcon: Icon(Icons.currency_rupee),),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.float(),
                          FormBuilderValidators.positiveNumber(),
                          FormBuilderValidators.numeric()
                        ]),
                      ),  
                     
                              
                        
                              
                      const SizedBox(height: 10),
                              
                      Text("Details (opt.)", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 4,),            
                      FormBuilderTextField(
                        name: 'billDetails',                        
                        decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline)),
                      ),
                      const SizedBox(height: 10,),

                      Text("Reciept Upload (opt.)", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 5,),   
                      FormBuilderFilePicker(                          
                          name: "Reciept",
                          decoration: InputDecoration(labelText: "New Reciept"),
                          maxFiles: 1,
                          previewImages: true,
                          typeSelectors: [
                            TypeSelector(
                              type: FileType.image,
                              selector: Row(
                                children: <Widget>[
                                  const Icon(Icons.add_a_photo_outlined),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("New Reciept"),
                                  ),
                                ],
                              ),
                            ),
                          ],              
                        ),
                    
                              
                      const SizedBox(height: 10,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed:(){
                              _onSubmit();
                              
                                const added = SnackBar(content: Text('Withdraw Sucessful'));
                                ScaffoldMessenger.of(context).showSnackBar(added);                                
                                Navigator.of(context).pop();
                                
                                
                              
                              
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
          : SafeArea(
      child: Scaffold(     
        
      
        body: ListView.builder(
          padding: const EdgeInsets.all(10.0),
           itemCount: _categorytransactions.isNotEmpty? _categorytransactions.length +1 : 2,
          itemBuilder:  (context, index){
          if(index == 0){
            return  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinAppTopNavigationBar(greeting: 'Manage Savings', titleGiven: 'Save and create a net'),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filled(
                    onPressed: (){
                      _showSetGoalModal();
                    },
                    icon: Icon(Icons.edit, color: Colors.black87,),
                  ),
                  
                  IconButton.filled(
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Info', style: Theme.of(context).textTheme.titleMedium),                            
                            content: Text('The Savings page is used to track funds you would keep aside for later, it cant be assigned to other categories and you can only withdraw it or deposit into it. It is your key for having a safety net in case needed!', style: TextStyle(
                              fontSize: 18
                            )),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK', style: TextStyle(color: Colors.blue), ),
                              ),
                            ],
                          );
                        },
                      );
                    }, 
                    icon: const Icon(Icons.info_outline, color: Colors.black87,),
                  ),
                ],                  
              ),
          
              const SizedBox(height: 10,),
              Text('Total Savings', style: Theme.of(context).textTheme.titleMedium,),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1, color: Colors.black54                    
                  ),
                  borderRadius: BorderRadiusGeometry.circular(10)
                ),
                leading: const Icon(Icons.monetization_on_outlined),
                title: Text(totalAmt.toStringAsFixed(2), style: Theme.of(context).textTheme.bodyMedium),
              ),
          
              const SizedBox(height: 10,),
              Row(
                spacing: 10,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goal Amount', style: Theme.of(context).textTheme.titleMedium,),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1, color: Colors.black54                    
                            ),
                            borderRadius: BorderRadiusGeometry.circular(10)
                          ),
                          leading:const Icon(Icons.monetization_on_outlined),
                          title: Text(goalAmt.toStringAsFixed(2), style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                spacing: 10,
                children: [
                  Flexible(
                        flex: 1,                    
                        child: TextButton.icon(                      
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            minimumSize: Size(double.maxFinite, 40),                        
                          ),                        
                          onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const AddToSavingsFormPage();
                              }));
                          }, 
                          icon: const Icon(Icons.call_received, color: Colors.black, size: 22,),     
                          iconAlignment: IconAlignment.end,                     
                          label: const Text("Add", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),)
                        
                          
                        ),
                      ),
                      Flexible(
                        flex: 1,                    
                        child: TextButton.icon(                      
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            minimumSize: Size(double.maxFinite, 40),                        
                          ),                        
                          onPressed: (){
                              _showForm();
                          }, 
                          icon: const Icon(Icons.call_made, color: Colors.black, size: 22,),     
                          iconAlignment: IconAlignment.end,                  
                          label: const Text("Withdraw", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),)
                        
                          
                        ),
                      ),
                ],
              ),
          
              const SizedBox(height: 20,),
              Card.outlined(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Column(
                      children: [
                        Text("Goal Completion Progress", style: Theme.of(context).textTheme.titleMedium,),
                        GoalProgressChart(completionPercentage: daPercent,),
                        
                        const SizedBox(height: 15),
          
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saved: ${totalAmt.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium,),                                
                              Text('Left: ${(leftAmt).toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium,)
                            ],
                          ),
                        ),
          
                      ],
                    ),
                  )),
          
              const SizedBox(height: 10,),
              Text('Previous Records', style: Theme.of(context).textTheme.titleMedium,),
          
            ],
            );
          }
          
          index -=1;

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
                  leading: _categorytransactions[index]['isReceived']==1 ? Icon(Icons.call_made, size: 32, color: Colors.red,) :  Icon(Icons.call_received, size: 32, color: Colors.green,),
                  title: Text(_categorytransactions[index]['details'] ?? 'No Details', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Paid on: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_categorytransactions[index]['txndatetime'])).toString()}'),
                  trailing: Text('${_categorytransactions[index]['amt'].toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
          
          
          }
          
        ),
      ),
    );
    
  }

  void _onSubmit() async {
    if (!_formKey6.currentState!.saveAndValidate()) return;
     final formValues = _formKey6.currentState!.value;
    final withdrawalAmt = double.tryParse(formValues['Amount']) ?? 0;

    // Prevent withdrawing more than saved
    if (withdrawalAmt > totalAmt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot withdraw more than total saved: ₹${totalAmt.toStringAsFixed(2)}')),
      );
      return;
    }
    final picked = _formKey6.currentState!.value['Reciept'] as List<PlatformFile>?;

    Uint8List? imageToSave; // default to existing image

    if (picked != null && picked.isNotEmpty) {
      final PlatformFile file = picked.first;
      Uint8List bytes;

      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file bytes')),
        );
        return;
      }

      imageToSave = bytes;
      
    }
    int newid = await SQLHelper.createRecord(
      1, 
      _formKey6.currentState!.value['billDetails'], 
      double.parse(_formKey6.currentState!.value['Amount'] as String), 
      DateTime.now().toString(), 
      imageToSave,
      3
    );
    await SQLHelper.addCategorydata(3, [newid]);
    _refreshJournal();
  }
}