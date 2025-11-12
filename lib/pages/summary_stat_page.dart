import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:FiniZen/widgets/statistics_page_category_list.dart';
import 'package:FiniZen/widgets/summary_pie_chart.dart';
import 'package:flutter/material.dart';


class SummaryStatPage extends StatefulWidget {
  final bool isExpense;
  const SummaryStatPage({super.key, required this.isExpense });

  @override
  State<SummaryStatPage> createState() => _SummaryStatPageState();
}

class _SummaryStatPageState extends State<SummaryStatPage> with RouteAware {
  List<Map<String, dynamic>> todoList= [];

  late bool cat;
  late final String greet;

  void _initsavings() async {
    setState(() {
      cat = widget.isExpense;
      greet = widget.isExpense ? 'Expense':'Income';
    });
    
    if (!mounted) return;
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
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FinAppTopNavigationBar(greeting: '$greet Statistics', titleGiven: 'Analyze and track graphically'),
               
                Card.filled(
                  surfaceTintColor: const Color.fromRGBO(110, 37, 148    ,1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 5),
                              child: IconButton.filled(onPressed: (){
                                setState(() {
                                  cat = widget.isExpense;
                
                                });
                              }, icon: Icon(Icons.refresh),color: Colors.black,),
                            ),
                            
                            
                          ],
                        ),
                        
                        SummaryPieChart(key: ValueKey(DateTime.now().millisecondsSinceEpoch),isExpenseChart: cat,),
                        const SizedBox(height: 10,)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Text('$greet Divisions', style: Theme.of(context).textTheme.titleMedium,),
                                               
                  ],
                ),
                StatisticsPageCategoryList(isExpenseCat: cat,) ,
                const SizedBox(height: 10,),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}