
import 'dart:io';
import 'dart:typed_data';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionFormPage extends StatefulWidget { 
  const AddTransactionFormPage({super.key});

  @override
  State<AddTransactionFormPage> createState() => _AddTransactionFormPage();
}

class _AddTransactionFormPage extends State<AddTransactionFormPage> {
  List<Map<String, dynamic>> _categories = [];
  List<String> catList = [];
  List<int> idList = [];
  int otherID = 1;
  bool _isLoading = true;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
 
  String b64='';
  var cangoNow = false;
  

  
  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() async {
    final data = await SQLHelper.getallcategories();
    setState(() {
      final isIncome = _formKey.currentState?.fields['transactionType']?.value == true;
      if(isIncome){
        _categories = data.where((item)=> (item['isReceived'] == 1 || item['isReceived'] == 2) && item['name']!='Savings').toList();
      } else if(!isIncome) {        
        _categories = data.where((item)=> (item['isReceived'] == 0 || item['isReceived'] == 2) && item['name']!='Savings').toList();      
      }
      catList = _categories.map<String>((item){
        idList.add(item['id']);
        if(item['name']=='Others') otherID = item['id'];
        return item['name'] as String;
      }).toList();
      
      _isLoading = false;
    });
  }

  @override
  void dispose() {  
    super.dispose();
  }
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {    
    return Scaffold(      
      body: SingleChildScrollView(
        child: SafeArea(
          child: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
          )
          :Padding(
            padding: const EdgeInsets.all(10.0),
            child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [   

                FinAppTopNavigationBar(greeting: 'Add Transaction', titleGiven: 'Add new Record'),



                const SizedBox(height: 10,),

                Text("Transaction Type", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                FormBuilderField<bool>(
                  name: 'transactionType', // true = income, false = expense
                  initialValue: false,
                  builder: (FormFieldState<bool?> field) {
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              field.didChange(true);
                              setState(() {
                                _refreshCategories(); // Refresh categories based on selection
                              });
                            },
                            child: Card(
                              color: field.value == true ? Colors.green[100] : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: field.value == true ? Colors.green : Colors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.call_received, size: 36, color: Colors.lightGreen),
                                    Text('Income', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              field.didChange(false);
                              setState(() {
                                _refreshCategories(); // Refresh categories based on selection
                              });
                            },
                            child: Card(
                              color: field.value == false ? Colors.red[100] : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: field.value == false ? Colors.red : Colors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.call_made, size: 36, color: Colors.red),
                                    Text('Expense', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text("Amount", style: Theme.of(context).textTheme.titleMedium,),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Amount',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Enter Amount', prefixIcon: Container(
                    alignment: Alignment.center,
                    width: double.minPositive,
                    child: Text(
                      currentcurrency,
                      style: TextStyle(fontSize: 18), // match your input text style
                    ),
                  ),),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.float(),
                    FormBuilderValidators.positiveNumber(),
                    FormBuilderValidators.numeric()
                  ]),
                ),
          
                const SizedBox(height: 10),
          
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Category", style: Theme.of(context).textTheme.titleMedium,),
                            
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
                        initialValue: otherID,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required()
                        ]),
                      )
                              
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text("Date", style: Theme.of(context).textTheme.titleMedium,),
                            
                      FormBuilderDateTimePicker(
                        name: 'billStartDate',                                                              
                        inputType: InputType.both,
                        initialDate: DateTime.now(),
                        initialValue: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        format: DateFormat('yyyy-MM-dd HH:mm'), 
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
          
                Text("Details (opt.)", style: Theme.of(context).textTheme.titleMedium,),
                const SizedBox(height: 4,),            
                FormBuilderTextField(
                  name: 'billDetails',
                  decoration: const InputDecoration(labelText: 'Enter Details', prefixIcon: Icon(Icons.info_outline)),
                  
                ),
              
          
                const SizedBox(height: 10,),
              
                Text("Reciept Upload (opt.)", style: Theme.of(context).textTheme.titleMedium,),
                const SizedBox(height: 5,),   
                FormBuilderField<List<PlatformFile>>(
                  name: 'Reciept',
                  builder: (FormFieldState<List<PlatformFile>?> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black54),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_library, size: 32,),
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowMultiple: false,
                                    withData: true,
                                  );
                                  if (result != null) {
                                    field.didChange(result.files);
                                  }
                                },
                                tooltip: 'Pick from Gallery',
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt, size: 32),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                          
                                  if (pickedFile != null) {
                                    final file = PlatformFile(
                                      name: pickedFile.name,
                                      size: await pickedFile.length(),
                                      path: pickedFile.path,
                                      bytes: await pickedFile.readAsBytes(),
                                    );
                                    field.didChange([file]);
                                  }
                                },
                                tooltip: 'Take a Photo',
                              ),
                            ],
                          ),
                        ),
                        if (field.value != null && field.value!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Image.memory(
                              field.value!.first.bytes!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText ?? '',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                      ],
                    );
                  },
                ),
          
          
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed:() async {
                        final ok = await _onSubmit();
                        if (ok) {
                          if (context.mounted) {
                            if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Record Added Successfully')),
                                );

                                // Give the snackbar time to show before navigating away
                                await Future.delayed(const Duration(milliseconds: 600));

                                // Only pop if still mounted
                                if (!mounted) return;
                                
                                Navigator.of(context)..pop()..pop();
                                                                                          
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
          ),
            
        ),
      ),
    );
  }
  Future<bool> _onSubmit() async {
    
    if (!_formKey.currentState!.saveAndValidate()) return false;

    // Get the selected files (may be empty)
    final picked = _formKey.currentState!.value['Reciept'] as List<PlatformFile>?;

    if (picked == null || picked.isEmpty) {
      debugPrint('No file picked');
      b64='';
      final mahid = await SQLHelper.createRecord(_formKey.currentState!.value['transactionType'] == true ? 1 : 0 , _formKey.currentState!.value['billDetails'], double.parse(_formKey.currentState!.value['Amount'] as String), _formKey.currentState!.value['billStartDate'].toString(), null,_formKey.currentState!.value['category'] as int);
      await SQLHelper.addCategorydata(_formKey.currentState!.value['category'] as int, [mahid]);

      return true;      
    }
    else{

    final PlatformFile file = picked.first;

    // Read the bytes (handles both mobile & desktop/web)
    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;                 // Web / desktop preview already in memory
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();  // Mobile, path must be non‑null
    } else {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read file bytes')),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst); // or popUntil
      return false;
    }

    
        
    final newid = await SQLHelper.createRecord(_formKey.currentState!.value['transactionType'] == true ? 1 : 0 , _formKey.currentState!.value['billDetails'], double.parse(_formKey.currentState!.value['Amount'] as String), _formKey.currentState!.value['billStartDate'].toString(), bytes, _formKey.currentState!.value['category'] as int);
    await SQLHelper.addCategorydata(_formKey.currentState!.value['category'] as int, [newid]);
    return true;

    }

  }
}
