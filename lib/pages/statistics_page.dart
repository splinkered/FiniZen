import 'package:carousel_slider/carousel_slider.dart';
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/categories_manager.dart';
import 'package:FiniZen/pages/savings_page.dart';
import 'package:FiniZen/pages/summary_stat_page.dart';
import 'package:FiniZen/pages/todo_widget_page.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/utils/export_excel.dart';
import 'package:FiniZen/utils/export_functionality.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:FiniZen/widgets/goal_progress_chart.dart';
import 'package:flutter/material.dart';


class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with RouteAware {
  List<Map<String, dynamic>> todoList= [];

  
  Map<String, dynamic> goalTotals= {};
  double totalAmt = 0;
  double daPercent= 0;
  double goalAmt = 0;
  void _initsavings() async {
    if (!mounted) return;
    final tmpTotal = await SQLHelper.getGoalTotals(); 
    final mahtotals = await SQLHelper.getTodos();
    final modifiableTotals = List<Map<String, dynamic>>.from(mahtotals);
    final appdbList = await SQLHelper.getappData();
    double glAmt = appdbList.first['currentgoalamt'];
    modifiableTotals.removeWhere((item)=> item['isComplete'] as int == 1);
    setState(() {
      todoList = modifiableTotals;
      goalTotals = tmpTotal; 
      totalAmt = goalTotals['spent']-goalTotals['received'];
      daPercent = (totalAmt/glAmt)*100;

      if(daPercent.isNegative || daPercent.isNaN){
        daPercent = 0;
      } else if(daPercent > 100.0){
        daPercent = 100.0;
      }
       
    });

    

    


     

    
  }


   @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      
    }


  @override
  void initState() {
    super.initState();    
     _initsavings();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  void didPopNext() {
   setState(() {
     _initsavings();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FinAppTopNavigationBar(greeting: 'Statistics', titleGiven: 'Analyze and track graphically'),
             
              
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return SummaryStatPage(isExpense:false);
                        }));
                      },
                      child: Card.outlined(                      
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(child: Column(
                            children: [
                              const Icon(Icons.call_made, size: 32,),
                              Text('Income Stat', style: Theme.of(context).textTheme.bodyMedium,)
                            ],
                          )),
                        ),
                      
                      ),
                    )
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return SummaryStatPage(isExpense: true);
                        }));
                      },
                      child: Card.outlined(                      
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(child: Column(
                            children: [
                              const Icon(Icons.call_received, size: 32,),
                              Text('Expense Stat', style: Theme.of(context).textTheme.bodyMedium,)
                            ],
                          )),
                        ),
                      
                      ),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextButton.icon(                
                        style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize:const Size(double.maxFinite, 55),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                          context: context,
                          elevation: 5,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (_) => ListView(
                            shrinkWrap: true,                            
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                  tileColor: Colors.lightGreenAccent,
                                  title: Text("All Categories", style: Theme.of(context).textTheme.titleLarge,),
                                  trailing: const  Icon(Icons.list_alt, size: 25,),
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return const CategoriesManager(isReceived: 2,);
                                    }));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                  tileColor: Colors.lightBlueAccent,
                                  title: Text("Recieved Categories", style: Theme.of(context).textTheme.titleLarge,),
                                  trailing: const  Icon(Icons.call_received, size: 25,),
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return const CategoriesManager(isReceived:1,);
                                    }));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                  tileColor: Colors.amberAccent,
                                  title: Text("Given Categories", style: Theme.of(context).textTheme.titleLarge,),
                                  trailing: const  Icon(Icons.call_made, size: 25,),
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return const CategoriesManager(isReceived:0,);
                                    }));
                                  },
                                ),
                              )
                            ],
                          ));
                        
                        },
                        icon: const Icon(Icons.format_list_bulleted_sharp, color: Colors.black, size: 20,),     
                        iconAlignment: IconAlignment.end,                     
                        label: const Text("Set Categories", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,),)
                        
                      ),
                    ),                    
                    
                  ],
                  
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,                    
                      child: TextButton.icon(                      
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: Size(double.maxFinite, 55),                        
                        ),                        
                        onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const SavingsPage();
                          }));
                        }, 
                        icon: const Icon(Icons.savings_outlined, color: Colors.black, size: 24,),     
                        iconAlignment: IconAlignment.end,                     
                        label: const Text("Manage Savings", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,),)
      
                        
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: EdgeInsets.all(10),
                child: CarouselSlider(
                    options: CarouselOptions(
                      height: 300, 
                      enableInfiniteScroll: false,
                      viewportFraction: 0.9,
                      disableCenter: true,
                      padEnds : false,
                    ),
                    items: [
                      Card.outlined(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text("Monthly Goal Completion Progress", style: Theme.of(context).textTheme.titleMedium,),
                            GoalProgressChart(completionPercentage: daPercent,),
                            
                            const Spacer(),
      
                            Row(
                              children: [
                                const Spacer(),
                                IconButton.filled(                
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,                                  
                                  ),    
                                  onPressed: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return const SavingsPage();
                                    }));
                                  }, 
                                  icon: const Icon(Icons.info, color: Colors.black, size: 20,),  
                                ),
                                const SizedBox(width: 10,)
                              ],
                            ),
      
                          ],
                        ),
                      )),
      
      
                      Card.outlined(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Column(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text("Finance ToDo List", style: Theme.of(context).textTheme.titleMedium,),
                            Flexible(
                              child:  todoList.isEmpty
                                ? Center(child: Text('No Data Recorded Yet!'))
                                : ListView.builder(
                                    itemCount: todoList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final todo = todoList[index];
                                      return Row(
                                        spacing: 10,
                                        children:[ 
                                          Icon(Icons.arrow_forward_ios, size: 20,),
                                          Expanded(child: Text(todo['item'], style: Theme.of(context).textTheme.titleMedium,)),
                                        ]
                                      );
                                    },
                                  ),
                            ),
                                                    
                            TextButton.icon(                
                              style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              minimumSize: const Size(150, 47),),    
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return const StatisticTodoWidget();
                                },));
                              }, 
                              icon: const Icon(Icons.edit_note, color: Colors.black, size: 20,),     
                              iconAlignment: IconAlignment.end,                 
                              label: const Text("Edit List", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,),)
                                  
                            ),
      
      
                          ],
                        ),
                      )),
      
                      Card.outlined(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Column(
                          children: [
                            Text("Data Export", style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 25,
      
                            )),
                            const Spacer(),
                            IconButton.filledTonal(                              
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadiusGeometry.circular(2)),
                                  backgroundColor: Colors.transparent,
                                  
                                ),
                                onPressed: (){
                                  showModalBottomSheet(
                                    context: context,
                                    elevation: 5,
                                    showDragHandle: true,
                                    isScrollControlled: true,
                                    builder: (_) => ListView(
                                      shrinkWrap: true,                            
                                      children: [
                                        Padding(
                                          
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: ListTile(
                                            shape: Border(
                                              bottom: BorderSide(width: 1, color: Colors.black54)
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                            //tileColor: Colors.lightGreenAccent,
                                            title: Text("Export Backup", style: Theme.of(context).textTheme.titleLarge,),
                                            trailing: const  Icon(Icons.handyman, size: 32,),
                                            onTap: () {
                                              
                                              _onExport();
                                              Navigator.of(context).pop();
                                              
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                            //tileColor: Colors.lightBlueAccent,
                                            title: Text("Excel Export", style: Theme.of(context).textTheme.titleLarge,),
                                            trailing: const  Icon(Icons.table_view, size: 32,),
                                            onTap: () {
                                              _onExcelExport();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        
                                      ],
                                    ));
                                  
                                }, 
                                icon:const  Icon(Icons.ios_share_outlined, size: 100, color: Colors.black54,)
                              ),
                            const Spacer(),
                          ],
                        ),
                      )),
                  ],
                ),
              ), 
      
            ],
          ),
        ),
      ),
    );
  }
  
  void _onExport() async {
    
    await exportAllDatabases(context);
 
  }
  void _onExcelExport() async {
    await exportFullDataAsZip(context);
  }
}