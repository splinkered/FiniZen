import 'dart:io';
import 'dart:typed_data';
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PayBill extends StatefulWidget {
  final int parentBillID;
  final String parentBillName;
  final String duedatetime;
  final double txnfrequency;

  const PayBill({    
    super.key,
    required this.parentBillID,
    required this.duedatetime,
    required this.txnfrequency, 
    required this.parentBillName
  });
  @override
  State<PayBill> createState() => _PayBill();  
}

class _PayBill extends State<PayBill> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  
  String b64='';
  var cangoNow = false;



  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bill'),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, size: 25,),
          onPressed: () => Navigator.of(context).pop(),
        ), 
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                      
                const SizedBox(height: 10,),
                Text("Enter Amount", style: Theme.of(context).textTheme.titleMedium,),
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
          
                  Row(                        
                  spacing: 10,
                  children: [
                    
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text("Date Paid On", style: Theme.of(context).textTheme.titleMedium,),
          
                          FormBuilderDateTimePicker(
                            name: 'billStartDate',        
                            inputType: InputType.both,
                            format: DateFormat('yyyy-MM-dd HH:mm'),                            
                            initialDate: DateTime.now(),
                            initialValue: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
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
                      )
                    ),
                  ],
                ),
          
          
                const SizedBox(height: 10),
          
                Text("Notes", style: Theme.of(context).textTheme.titleMedium,),
                const SizedBox(height: 4,),            
                FormBuilderTextField(
                  name: 'billDetails',
                  decoration: const InputDecoration(labelText: 'Enter Notes', prefixIcon: Icon(Icons.info_outline)),
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
                            const added = SnackBar(content: Text('Bill Paid Sucessfully'));
                            ScaffoldMessenger.of(context).showSnackBar(added);
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
    );
  }

  Future<bool> _onSubmit() async {
    
    final int isallPaid;
    widget.txnfrequency == 0.0?  isallPaid =1:isallPaid = 0;
    
    if (!_formKey.currentState!.saveAndValidate()) return false;

    // Get the selected files (may be empty)
    final picked = _formKey.currentState!.value['Reciept'] as List<PlatformFile>?;

    if (picked == null || picked.isEmpty) {
      debugPrint('No file picked');
      final txnid = await SQLHelper.createbilltransactionRecord(_formKey.currentState!.value['billDetails'], double.parse(_formKey.currentState!.value['Amount'] as String), _formKey.currentState!.value['billStartDate'].toString(), widget.duedatetime , null, widget.parentBillName ); 
    
      final newid =await SQLHelper.updateBilldata(widget.parentBillID, txnid, double.parse(_formKey.currentState!.value['Amount'] as String), DateTime.parse(widget.duedatetime).add(Duration(days: (widget.txnfrequency * 30).toInt() )).toString(), isallPaid);
      final addid  = await SQLHelper.addCategorydata(2, [txnid]);
    
      return true;      
    }
    else{

    final PlatformFile file = picked.first;

    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!; 
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      const maherror = SnackBar(content: Text('Could not read file bytes'));
      ScaffoldMessenger.of(context).showSnackBar(maherror);
      Navigator.of(context)..pop()..pop();
      return false;
    }
    
   
        
    final txnid = await SQLHelper.createbilltransactionRecord(_formKey.currentState!.value['billDetails'], double.parse(_formKey.currentState!.value['Amount'] as String), _formKey.currentState!.value['billStartDate'].toString(), widget.duedatetime , bytes, widget.parentBillName);   
    
    final newid = await SQLHelper.updateBilldata(widget.parentBillID, txnid, double.parse(_formKey.currentState!.value['Amount'] as String), DateTime.parse(widget.duedatetime).add(Duration(days: (widget.txnfrequency * 30 ).toInt() )).toString(), isallPaid);
   
    final addid  = await SQLHelper.addCategorydata(2, [txnid]);
    
    
    return true;

    }

  }
  
}
