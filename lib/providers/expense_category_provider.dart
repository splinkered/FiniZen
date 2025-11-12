import 'package:flutter/foundation.dart';

class ExpenseCategoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _categories = [];



  List<Map<String, dynamic>> get categories {
    return _categories;    
  }

  void addCategory(String name, double value) async {    
    _categories.add({'name':name, 'value':value});
    notifyListeners();
  }
  void clearCategories() {
    _categories.clear();
    notifyListeners();
  }
}