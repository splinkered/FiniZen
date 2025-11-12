import 'package:FiniZen/database/db_manager.dart';
import 'package:flutter/foundation.dart';

class RecordsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _records = [];

  List<Map<String, dynamic>> get records {
    _refreshRecords();
    return _records;
    
  }

  void _refreshRecords() async {
    final data = await SQLHelper.getRecords();
    _records = data;
  }

  void freshRecords() async {
    final data = await SQLHelper.getRecords();
    _records = data;
    notifyListeners();
  }

}