
import 'package:FiniZen/pages/add_bill.dart';
import 'package:FiniZen/pages/add_category.dart';
import 'package:FiniZen/pages/add_transaction_form_page.dart';
import 'package:FiniZen/utils/import_functionality.dart';
import 'package:flutter/material.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15)
            )            
          ),
          title:  const Text("Add", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35, 
            overflow: TextOverflow.ellipsis,
            decoration: TextDecoration.none,
            color: Colors.black87,
          )),
          leading: ModalRoute.of(context)?.canPop == true? IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 35,
              ),onPressed: () => Navigator.of(context).pop(), ) : null,
          ),
        body: GridView.count(
            crossAxisCount: 2,          
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return AddTransactionFormPage();
                  }));
                },

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const  Icon(Icons.account_balance_wallet, size: 60, color: Colors.black87,),
                    Text("Transaction", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
              ),



              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context){
                      return const AddBill();
                    }
                  
                  ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt, size: 60, color: Colors.black87,),
                    Text("Bill", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
              ),


              GestureDetector(

                onTap: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: 
                    (context) { return const AddCategory();}
                  ));
                },

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt, size: 60, color: Colors.black87,),
                    Text("Categories", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
              ),            
              GestureDetector(
                onTap: () async{
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('The current data will be replaced, Are you sure you want to import?'),
                    action: SnackBarAction(
                      label: 'YES',
                      textColor: Colors.redAccent,
                      onPressed: () async {
                         importAndReplaceDatabases(context);
                      },
                    ),
                  ),
                );
                 
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.system_update_alt, size: 60, color: Colors.black87,),
                    Text("Import", style: Theme.of(context).textTheme.titleMedium,),
                    Text('(Will Replace the Current Data)', style: Theme.of(context).textTheme.bodyLarge,)

                  ],
                ),
              ),
            ]
          ),
      ),
    );
  }
}