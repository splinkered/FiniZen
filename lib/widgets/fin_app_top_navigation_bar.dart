import 'package:flutter/material.dart';

class FinAppTopNavigationBar extends StatelessWidget {
  final String greeting;
  final String titleGiven;

  const FinAppTopNavigationBar({
    super.key,
    required this.greeting,
    required this.titleGiven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
              color: const Color.fromRGBO(110, 37, 148  ,0),
              padding: const EdgeInsets.all(10.0),
              child: Row(
                
                children: [
                 Navigator.canPop(context)? IconButton(onPressed: (){Navigator.of(context).pop();}, icon:Icon(Icons.arrow_back_ios_new, size: 32,)) : IconButton.filledTonal(
                    onPressed: (){},
                    style: IconButton.styleFrom(backgroundColor: const Color.fromRGBO(0,0,0,0.75)),
                    color: const Color.fromRGBO(255,255,255,1),
                    icon: const Icon(Icons.person_2_rounded), 
                    iconSize: 30,                  
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    
                  ),
                  const SizedBox(width: 15,),
                  Expanded(
                    child: Column(                  
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting,style: Theme.of(context).textTheme.titleMedium),
                      Text(titleGiven, softWrap: true, style: TextStyle(fontWeight:  FontWeight.bold,
              fontSize: 16,),
                  overflow: TextOverflow.visible),
                    ],
                                            ),
                  ),
                  
                ],                  
              ),
              
            );
  }
}