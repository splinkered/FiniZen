import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';



class AddCategory extends StatefulWidget { 
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategory();
}

class _AddCategory extends State<AddCategory> {

  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();


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
                const FinAppTopNavigationBar(greeting: 'Add Category', titleGiven: 'Payments will be made under the same'),
                Text("Add New Category", style: Theme.of(context).textTheme.titleLarge,),
                FormBuilder(
                  key: _billformKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      const SizedBox(height: 10,),
                      
                        Row(                        
                        spacing: 10,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text("Name", style: Theme.of(context).textTheme.titleMedium,),

                                FormBuilderTextField(
                                  name: 'BillName',
                                  decoration: const InputDecoration(labelText: 'Enter Name', prefixIcon: Icon(Icons.info_outline)),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.maxLength(20)
                                  ]),
                                )
                  
                              ],
                            )
                          ),
                          
                        ],
                      ),


                      const SizedBox(height: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text("Details(opt.)", style: Theme.of(context).textTheme.titleMedium,),
                                            
                          FormBuilderTextField(
                            name: 'billDetails',
                            decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline)),
                           
                          )
                                      
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
                            title: const Text('Is the category used to track Income?', style: TextStyle(fontSize: 20),),
                            initialValue: false,
                            onChanged: (bool? value) {},
                            activeColor: Colors.deepPurpleAccent,
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
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category added successfully')));                                
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
    
        
    await SQLHelper.createcategory(      
      _billformKey.currentState!.value['BillName'],       
      _billformKey.currentState!.value['billDetails'],
      '[]',
      _billformKey.currentState!.value['isReceived'] ? 1 : 0,
    );

    return true;
    
  }
}
