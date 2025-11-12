import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';



class AddBill extends StatefulWidget { 
  const AddBill({super.key});

  @override
  State<AddBill> createState() => _AddBill();
}

class _AddBill extends State<AddBill> {

  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  String initalValue = "abc";


  @override
  void initState() {
    super.initState();
  }
  final GlobalKey<FormBuilderState> _billformKey = GlobalKey<FormBuilderState>();
  
  @override
  void dispose() {
    super.dispose();
  }
  

  

  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FinAppTopNavigationBar(greeting: 'Add Bill', titleGiven: 'A recurring payment will be added'),
                Text("Add New Bill", style: Theme.of(context).textTheme.titleLarge,),
                FormBuilder(
                  key: _billformKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      const SizedBox(height: 10,),
                      
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text("Bill Name", style: Theme.of(context).textTheme.titleMedium,),
                                                
                            FormBuilderTextField(
                              name: 'BillName',
                              decoration: const InputDecoration(labelText: 'Enter Name', prefixIcon: Icon(Icons.info_outline)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            )
                                        
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text("Current Due Date", style: Theme.of(context).textTheme.titleMedium,),
                                                
                            FormBuilderDateTimePicker(
                              name: 'billStartDate',                                                              
                              inputType: InputType.both,
                              format: DateFormat('yyyy-MM-dd HH:mm'), 
                              initialDate: DateTime.now(),
                              initialValue: DateTime.now(),                            
                              onChanged: (DateTime? value) {},
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.dateTime()
                              ]),
                              decoration: const InputDecoration(
                                labelText: 'Select Date & Time',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                                        
                          ],
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
                                Text("Details(opt.)", style: Theme.of(context).textTheme.titleMedium,),

                                FormBuilderTextField(
                                  name: 'billDetails',
                                  decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline)),
                                 
                                )
                  
                              ],
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        children: [
                          Text("Frequency of Payment(opt.)", style: Theme.of(context).textTheme.titleMedium,),
                          Text("in Months", style: Theme.of(context).textTheme.bodyMedium,),
                          SizedBox(height: 4,),
                          FormBuilderSlider(
                            name: 'frequency_slider',                                  
                            min: 0,
                            max: 12,
                            divisions: 24,
                            initialValue:0,
                            onChanged: (double? value) {},
                            
                          ),
                                            
                        ],
                      ),
                      const SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed:() async{
                              final ok = await _submit(); 
                               if (ok) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill added successfully')));                                
                                  Navigator.of(context).popUntil((r) => r.isFirst);
                                }
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
              ],
            ),
          ),
            
        ),
      ),
    );
  }
  Future<bool> _submit() async{
    if (!(_billformKey.currentState?.saveAndValidate() ?? false)) return false;
    
        
    await SQLHelper.createBill(
      -1, 
      _billformKey.currentState!.value['BillName'], 
      _billformKey.currentState!.value['billDetails'],       
      _billformKey.currentState!.value['frequency_slider'] as double,
      _billformKey.currentState!.value['billStartDate'].toString(), 
      '[]'
    );

    return true;
    
  }
}
