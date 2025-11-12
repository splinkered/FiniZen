import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/providers/expense_category_provider.dart';
import 'package:FiniZen/providers/income_category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPageCategoryList extends StatelessWidget {
  final bool isExpenseCat;
  const StatisticsPageCategoryList({super.key, required this.isExpenseCat});

  @override
  Widget build(BuildContext context) {
    final provider;
    if(isExpenseCat){provider = Provider.of<ExpenseCategoryProvider>(context);}
    else{provider = Provider.of<IncomeCategoryProvider>(context);}
    //print(provider.categories.length);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.categories.length,
      itemBuilder: (context, index) {
        final category = provider.categories[index];
        final String amt = category['value'].toStringAsFixed(2);
        return ListTile(
              //title: Text("${category['name']} $index", style: Theme.of(context).textTheme.titleMedium,),
              title: Text("${category['name']}", style: Theme.of(context).textTheme.titleMedium,),
              leading: const Icon(Icons.tag, color: Colors.black87, size: 25,),
              trailing: Text("$currentcurrency $amt", style: TextStyle(fontSize: 16),),
            );
      }
    );
  }
}