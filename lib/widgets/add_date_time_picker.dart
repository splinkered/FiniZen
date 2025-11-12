import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDateTimePicker extends StatefulWidget {
  const AddDateTimePicker({super.key});

  @override
  State<AddDateTimePicker> createState() => _AddDateTimePicker();
}

class _AddDateTimePicker extends State<AddDateTimePicker> {
  DateTime? selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(      
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1998),
      lastDate:  DateTime.now(),
      builder:(context, child) {
        return Theme(data: Theme.of(context).copyWith(
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(               
                foregroundColor: Colors.black87, // button text color
              ),
            ),
          ),
        
          child: child! );
      },
    );

    setState(() {
      selectedDate = pickedDate;
      //print(selectedDate.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          selectedDate != null
              ? DateFormat('dd-MM-yyyy hh:mm a').format(selectedDate as DateTime).toString()
              : 'No Date is Entered',
        style: TextStyle(fontSize: 20),),
        Row(
          children: [
            Expanded(child: FilledButton(onPressed: _selectDate,  child: const Text('Change Date', style: TextStyle(fontSize:14, fontWeight: FontWeight.bold, color: Colors.black87),))),
          ],
        ),
      ],
    );
  }
}