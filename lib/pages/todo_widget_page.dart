import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/widgets/fin_app_top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StatisticTodoWidget extends StatefulWidget {
  const StatisticTodoWidget({super.key});

  @override
  State<StatisticTodoWidget> createState() => _StatisticTodoWidgetState();
}

class _StatisticTodoWidgetState extends State<StatisticTodoWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> todoList= [];
  final _formKey7 = GlobalKey<FormBuilderState>();
  Set<int> toggledTodos = {};

  void _loadTodo() async {
    final totals = await SQLHelper.getTodos();
    final modifiableTotals = List<Map<String, dynamic>>.from(totals);

    modifiableTotals.sort((a, b) {
      return a['isComplete'].compareTo(b['isComplete']);
    });

    setState(() {
      todoList = modifiableTotals;      
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTodo();

    
  }

  @override
  void dispose() {    
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
            child: SingleChildScrollView(
              child: Column(     
                spacing: 10,  
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [  
                  const FinAppTopNavigationBar(greeting: 'Todo Page', titleGiven: 'Write down goals!'),  
                            
                 FormBuilder(
                  key: _formKey7,
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black54),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.check),
                    ),
                    title: FormBuilderTextField(
                      name: 'task',
                      cursorColor: Colors.black87,
                      decoration: const InputDecoration(
                        hintText: "Enter todo task",
                        border: InputBorder.none,
                      ),
                    ),
                    trailing: IconButton.outlined(
                      onPressed: _addTodo,
                      padding: const EdgeInsets.all(11),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
                          
                 ListView.builder(
                   itemCount: todoList.length,
                   shrinkWrap: true,
                   itemBuilder: (context, index) {
                     final todo = todoList[index];
                     final id = todo['id'];
                     final isComplete = todo['isComplete'] == 0;
                           
                     if (!isComplete) {
                       // Show cut text for completed items
                       return Container(
                         padding: const EdgeInsets.all(5.0),
                         child: Container(
                           decoration: BoxDecoration(
                             border: Border.all(width: 1, color: Colors.black87),
                             borderRadius: BorderRadius.circular(5),
                           ),
                           child: ListTile(
                             trailing: IconButton(onPressed: (){
                               _deletetoDo(id);
                               _loadTodo();
                               const added = SnackBar(content: Text('Todo Deleted Sucessfully'));
                               ScaffoldMessenger.of(context).showSnackBar(added);                                    
                             }, icon: Icon(Icons.delete_forever, color: Colors.red,)),
                             title: Text(
                               todo['item'],
                               style: const TextStyle(
                                 decoration: TextDecoration.lineThrough,
                                 color: Colors.grey,
                               ),
                             ),
                           ),
                         ),
                       );
                     }
                           
                     
                     return Container(
                       padding: const EdgeInsets.all(5.0),
                       child: Container(
                         decoration: BoxDecoration(
                           border: Border.all(width: 1, color: Colors.black87),
                           borderRadius: BorderRadius.circular(5),
                         ),
                         child: ListTile(
                           trailing: Checkbox(
                             checkColor: Colors.black87,
                             value: toggledTodos.contains(id),
                             onChanged: (val) {
                               setState(() {
                                 if (val == true) {
                                   toggledTodos.add(id); 
                                 } else {
                                   toggledTodos.remove(id);
                                 }
                               });
                             },
                           ),
                           title: Text(todo['item']),
                         ),
                       ),
                     );
                   },
                 ),                      
                  
                  const SizedBox(height: 65,)
                    
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(onPressed: () {
           _saveTodo();
           Navigator.pop(context);
        },
          tooltip: 'Save the changes',
          child: Icon(Icons.save),
          ),
    );
    
  }
  void _saveTodo() async {
    for (int id in toggledTodos) {
      await SQLHelper.updateTodoCompletion(id, 1); // Set isComplete to 1
    }
    toggledTodos.clear();
    _loadTodo(); // Refresh list
  }
  void _addTodo() async {
  if (_formKey7.currentState?.saveAndValidate() ?? false) {
    final task = _formKey7.currentState!.value['task'];
    if (task != null && task.toString().trim().isNotEmpty) {
      await SQLHelper.createTodo(task, 0);
      _formKey7.currentState!.reset();
      _loadTodo();
    }
  }
}

void _deletetoDo(meid) async{
  await SQLHelper.deleteTodo(meid);
}
  
}

