import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  // List of items in our dropdown menu
  final List<String> items;

  const DropdownWidget({super.key, required this.items});  

  @override  
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  
  late String dropdownValue;
  
  @override
  void initState() {
    super.initState();
    dropdownValue = widget.items.first;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return  DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward, size: 18,),
      elevation: 16,
      style: const TextStyle(color: Colors.black87),
      underline: Container(height: 2, color: Colors.transparent),      
      focusColor: Colors.transparent,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items:
          widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
    
  }
}