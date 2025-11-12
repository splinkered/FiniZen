import 'package:flutter/material.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({super.key});

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {

  DateTime? selectedDate;

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
    return Row(
      
      spacing: 20,
      children: <Widget>[
        //below Text is very imp
        // Text(
        //   selectedDate != null
        //       ? selectedDate.toString()
        //       : 'No Date is Entered',
        // ),
        FilledButton(onPressed: _selectDate, child: const Text('Select Date', style: TextStyle(fontSize:14, fontWeight: FontWeight.bold, color: Colors.black87),)),
      ],
    );
  }
}