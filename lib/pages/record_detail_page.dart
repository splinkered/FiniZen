import 'dart:io';
import 'dart:typed_data';
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

void showPhotoViewDialog(BuildContext context, String imagePath) async {
  final file = File(imagePath);

  if (!await file.exists()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image not found')),
    );
    return;
  }

  final imageBytes = await file.readAsBytes();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PhotoView(
                imageProvider: MemoryImage(imageBytes),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                tightMode: true,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.white),
              onPressed: () async {
                final result = await ImageGallerySaverPlus.saveFile(imagePath);
                final isSuccess = result['isSuccess'] ?? result['filePath'] != null;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSuccess ? 'Image saved to gallery' : 'Failed to save image',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class RecordDetailPage extends StatefulWidget {
  final int id;
  
  const RecordDetailPage({super.key,required this.id});

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
 String? recieptImagePath;
 List<Map<String, dynamic>> _categories = [];
  List<DropdownMenuItem<int>> catList = [];
  List<int> idList = [];
  String greet= '';
  int otherID = 1;
  final GlobalKey<FormBuilderState> _formKey2 = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _journal = {};
  bool _isLoading = true;

  void _refreshJournal() async {
    final data = await SQLHelper.getallcategories();
    final jrdata = await SQLHelper.getRecord(widget.id);
    setState(() {
      _journal = jrdata[0];
      greet = _journal['isReceived'] == 1 ? 'Income' : 'Expense';
      recieptImagePath = _journal['imageBase64'];
      if(_journal['isReceived'] == 1){
        _categories = data.where((item)=> (item['isReceived'] == 1 || item['isReceived'] == 2)).toList();
      } else if(_journal['isReceived'] ==0) {
        _categories = data.where((item)=> (item['isReceived'] == 0 || item['isReceived'] == 2)).toList();      
      }
    

      catList = _categories.map<DropdownMenuItem<int>>(
        (item) => DropdownMenuItem<int>(
          value: item['id'] as int,
          child: Text(item['name'] as String),
        )).toList();

        catList.removeWhere((item)=> item.value == 3);


      
      _isLoading = false;
    });
  }
  

  @override
  void initState() {
    super.initState();
    _refreshJournal(); 
  }


  @override
  void dispose() {
    super.dispose();
  } 
  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteRecord(id);  
  }

  void _showDeleteSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Delete this record?'),
        action: SnackBarAction(
          label: 'DELETE',
          textColor: Colors.redAccent,
          onPressed: () async {
            await _deleteItem(widget.id);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Record deleted')),
            );
          },
        ),
      ),
    );
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 90,
              ),
              child: SizedBox(
                height: 461,
                child: SingleChildScrollView(
                  child: FormBuilder(
                  key: _formKey2,
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      
                      const SizedBox(height: 10,),
                      Text("Edit Record", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 10,),
                      FormBuilderTextField(
                        name: 'Amount',
                        keyboardType: TextInputType.number,
                        initialValue: _journal['amt'].toStringAsFixed(2),
                        decoration: InputDecoration(labelText: 'Enter Amount', prefixIcon:Container(
                          alignment: Alignment.center,
                          width: double.minPositive,
                          child: Text(
                            currentcurrency,
                            style: TextStyle(fontSize: 18), 
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
                                Text("Category", style: Theme.of(context).textTheme.titleMedium,),
                              
                                FormBuilderDropdown<int>(
                                  name: 'category',
                                  menuMaxHeight: 250,
                                  items: catList,
                                      
                                  onChanged: (int? value) {
                                    debugPrint('Selected category id: $value');
                                  },
                                  initialValue: _journal['categoryid'] as int,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required()
                                  ]),
                                )
                  
                              ],
                            )
                          ),
                              
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text("Date", style: Theme.of(context).textTheme.titleMedium,),
                              
                                FormBuilderDateTimePicker(
                                  name: 'billStartDate',                                                              
                                  inputType: InputType.both,
                                  initialDate: DateTime.parse(_journal['txndatetime']),
                                  initialValue: DateTime.parse(_journal['txndatetime']),
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
                            )
                          ),
                        ],
                      ),
                              
                              
                      const SizedBox(height: 10),
                              
                      Text("Details (opt.)", style: Theme.of(context).textTheme.titleMedium,),
                      const SizedBox(height: 4,),            
                      FormBuilderTextField(
                        name: 'billDetails',
                        initialValue: _journal['details'],
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
                            onPressed:(){
                              _onSubmit();
                              
                                const added = SnackBar(content: Text('Record Edited Sucessfully'));
                                ScaffoldMessenger.of(context).showSnackBar(added);                                
                                Navigator.of(context).pop();
                                _refreshJournal();
                              
                              
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
      
        appBar: AppBar(
        toolbarHeight: 60,
        //backgroundColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15)
          )            
        ),
        title:  Text("$greet Detail", style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20, 
          overflow: TextOverflow.ellipsis,
          decoration: TextDecoration.none,
          color: Colors.black87,
        )),
        leading: ModalRoute.of(context)?.canPop == true? IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 25,
            ),onPressed: () {            
              Navigator.of(context).pop();
            }) : null,
        ),
      
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [  
                _journal['categoryid']== 3 ? 
                  
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
                      onPressed: () => _showDeleteSnackBar(context),
                      icon: const Icon(Icons.delete_forever, color: Colors.black87,),
                    ),                    
                  ],                  
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: Theme.of(context).textTheme.titleMedium,),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1, color: Colors.black54                    
                        ),
                        borderRadius: BorderRadiusGeometry.circular(10)
                      ),
                      leading: Text(currentcurrency, style: Theme.of(context).textTheme.titleMedium,),
                      title: Text(_journal['amt'].toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium,),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: Theme.of(context).textTheme.titleMedium,),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1, color: Colors.black54                    
                        ),
                        borderRadius: BorderRadiusGeometry.circular(10)
                      ),
                      leading: const Icon(Icons.tag),
                      title: Text( _categories.firstWhere( (cat) => cat['id'] as int == _journal['categoryid'] as int )['name'], style: Theme.of(context).textTheme.bodyLarge,),
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
                  title: Text( _journal['details'] ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    
                  ),overflow: TextOverflow.clip,),
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date Time', style: Theme.of(context).textTheme.titleMedium,),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1, color: Colors.black54                    
                                  ),
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                leading: const Icon(Icons.calendar_month),
                                title: Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(_journal['txndatetime'])).toString(), style: Theme.of(context).textTheme.titleMedium,),
                              )
                            ],
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 10,),

                Row(
                  spacing: 10,
                  children: [                    
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reciept', style: Theme.of(context).textTheme.titleMedium,),
                           (recieptImagePath == null || recieptImagePath!.isEmpty) ? Text("No Reciept Uploaded") :
                           Row(
                            spacing: 5,
                             children: [
                               Flexible(
                                 child: OutlinedButton(
                                    onPressed: () {
                                      showPhotoViewDialog(context, recieptImagePath!);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.maxFinite,55)
                                    ),
                                    child: Text('View Image', style: Theme.of(context).textTheme.titleMedium,), 
                                  ),
                               ),
                                _journal['categoryid']== 3 ? Container() :
                                IconButton.outlined(
                                  onPressed: () async {
                                    if (recieptImagePath != null && recieptImagePath!.isNotEmpty) {
                                      final file = File(recieptImagePath!);
                                      bool deleted = false;

                                      // Attempt to delete the image file from local storage
                                      if (await file.exists()) {
                                        try {
                                          await file.delete();
                                          deleted = true;
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to delete image file')),
                                          );
                                          return;
                                        }
                                      } else {
                                        deleted = true; // File not found, consider it deleted
                                      }

                                      if (deleted) {
                                        // Update database: set imageBase64 to null or ''
                                        await SQLHelper.updateRecordImagePath(widget.id, null); // You need to implement this

                                        // Update UI state
                                        setState(() {
                                          recieptImagePath = null;
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Image removed successfully')),
                                        );
                                      }
                                    }
                                  }, icon: Icon(Icons.delete_forever, color: Colors.red, size: 35,))
                             ],
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
                )
                
              ],
            ),
          ),
        ),
      ),
    );

  }

  void _onSubmit() async {
  if (!_formKey2.currentState!.saveAndValidate()) return;

  final picked = _formKey2.currentState!.value['Reciept'] as List<PlatformFile>?;

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
  
  await SQLHelper.updateRecord(
    widget.id,
    _journal['isReceived'],
    _formKey2.currentState!.value['billDetails'],
    double.parse(_formKey2.currentState!.value['Amount'] as String),
    _formKey2.currentState!.value['billStartDate'].toString(),
    imageToSave,
    _formKey2.currentState!.value['category'] as int
  );
  if(_formKey2.currentState!.value['category'] as int != _journal['categoryid']){
    await SQLHelper.removeIdListFromCategoryData(_journal['categoryid'] as int, [_journal['id'] as int]);
    await SQLHelper.addCategorydata(_formKey2.currentState!.value['category'] as int, [_journal['id'] as int]);
  }

}
  
}