import 'package:flutter/material.dart';

class DashboardRecordCard extends StatelessWidget {
  
  const DashboardRecordCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: const Color.fromRGBO(252, 247, 248    ,1),                        
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(                                
              padding: EdgeInsets.all(10),                                
              child: const Icon(Icons.call_received, size: 27, color: Colors.green,),
            ),
            Expanded(
              child: Column(     
                         
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payment From Manoj Sharma, Manoj Sharma, Manoj Sharma, Manoj Sharma, Manoj Sharma, ", style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis,),
                  const Text("04:03 PM"),                                                                    
                ],                                
              ),
            ),
            const Text("- ₹200", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.end,),
          ],
        ),
      ),
    );
  }
}