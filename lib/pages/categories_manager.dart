import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/category_detail_page.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';

class CategoriesManager extends StatefulWidget {
  final int isReceived;
  const CategoriesManager({super.key, required this.isReceived});

  @override
  State<CategoriesManager> createState() => _CategoriesManagerState();
}

class _CategoriesManagerState extends State<CategoriesManager> with RouteAware{
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();    
    routeObserver.subscribe(this, ModalRoute.of(context)!);     
  }

  void _refreshCategories() async {
    final data = await SQLHelper.getallcategories();
    setState(() {
      if(widget.isReceived == 1){
        _categories = data.where((item)=> (item['isReceived'] == 1 || item['isReceived'] == 2)).toList();
      } else if(widget.isReceived == 0) {        
        _categories = data.where((item)=> (item['isReceived'] == 0 || item['isReceived'] == 2)).toList();      
      } else{
        _categories = data;
      }
      
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();

  }

  @override
  void didPopNext() {
   setState(() {
    _refreshCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      
        body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
            
            child: ListView.builder(    
            itemCount:  _categories.isNotEmpty? _categories.length +1 : 2 ,
            itemBuilder: (context, index){
              if(index == 0){
               return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  FinAppTopNavigationBar(greeting: 'Category Manager', titleGiven: 'View/Edit/Delete Categories'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                    spacing: 5,
                    children: [
                      Text('All Categories', style: Theme.of(context).textTheme.titleMedium,)
                    ]
                                
                                    ),
                  ),
                 ],
               );
              }
              index -=1;
              return _categories.isEmpty ? Center(child:Column(
                children: [
                  Text('No Category Recorded Yet'),
                  const Text('Add a category from the Add Button in dashboard')
                ],
              )) :
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CategoryDetailPage(id: _categories[index]['id']);
                      }));
                    
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Colors.black54                    
                      ),
                      borderRadius: BorderRadiusGeometry.circular(10)
                        
                  ),        
                  leading:  Icon(Icons.monetization_on_outlined, size: 32, color:Colors.black87),
                  title: Text(_categories[index]['name']!=null ? _categories[index]['name']! : '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(_categories[index]['notes']?? 'No details'),
                  // trailing: Text('${_categories[index]['curbillamt']}', style: Theme.of(context).textTheme.bodyLarge,),
                )
              );
            }
                          ),
          ),          
      ),
    );
  }
}