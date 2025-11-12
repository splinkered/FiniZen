import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/pages/statistics_page.dart';
import 'package:flutter/material.dart';

class DashboardMainCarouselItem extends StatefulWidget {
  final String title;
  final double amt;
  const DashboardMainCarouselItem({super.key, required this.title, required this.amt});
  
  @override
  State<DashboardMainCarouselItem> createState() => _DashboardMainCarouselItemState();
}

class _DashboardMainCarouselItemState extends State<DashboardMainCarouselItem> {
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.symmetric(horizontal:2),
        child: Card(
          surfaceTintColor: const Color.fromRGBO(110, 37, 148    ,1),
          
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: Column(                  
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 27,),),
                const Spacer(flex: 1),
                Row(
                  
                  children: [
                    const Spacer(flex: 10,),
                    Text("$currentcurrency ${widget.amt.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 40, overflow: TextOverflow.ellipsis),),
                    const Spacer(flex: 1,)
                  ],
                ),
                if(widget.title == 'Overall Balance')
                    Container(
                      margin: EdgeInsets.all(10),
                      alignment: AlignmentGeometry.directional(0, 0),
                      
                      child: ElevatedButton(                        
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(150, 50)                 
                      ),
                        onPressed: (){                      
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const  StatisticsPage();
                          }));             
                        }, 
                        child: const Text("Statistics", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),)
                      
                      ),
                    ) ,
              ],
            ),
          ),
        ),
      );
  }
}