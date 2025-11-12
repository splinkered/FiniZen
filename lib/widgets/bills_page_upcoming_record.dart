import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillsPageUpcomingRecord extends StatelessWidget {
  final int id;
  final String details;
  final double amt;
  final String datetime;

  const BillsPageUpcomingRecord({
    super.key,
    required this.id,
    required this.details,
    required this.amt,
    required this.datetime,
  });
  
  @override
  Widget build(BuildContext context) {
    
    return Card.outlined(
      color: Color.fromRGBO(252, 247, 248    ,1),                        
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(                                
              padding: const  EdgeInsets.all(10),                                
              child: IconButton.filledTonal(
                icon:const Icon(Icons.more_vert, size: 27, ),
                onPressed: (){},
              ),
            ),
            Expanded(
              child: Column(     
                         
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis,),
                  Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(datetime)).toString()),                                                              
                ],                                
              ),
            ),
            Text("- $amt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.end,),
          ],
        ),
      ),
    );
  }
}