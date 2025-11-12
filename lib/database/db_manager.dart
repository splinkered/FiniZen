import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static sql.Database? _recordsDb;
  static sql.Database? _appDataDb;
  static sql.Database? _billsDb;
  static sql.Database? _billtransactionrecordsDb;  
  static sql.Database? _categoryDb;
  static sql.Database? _todoDb;

  static String sanitizeFileName(String input) {
    // Replace anything that's not a letter, number, or underscore with "_"
    return input.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  }

  static Future<void> initAllDatabases() async {
    await recordDb();
    await billDb();
    await appDataDb();
    await billtransactionrecordsDb();
    await categoryDb();
    await todoDb();
  }


  Future<String> getCustomTxnImageDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(join(dir.path, 'txn_images'));

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
    }

    return imageDir.path;
  }
    Future<String> saveTxnImageFile(Uint8List imageBytes, String details, int id, DateTime time) async {
    final folderPath = await getCustomTxnImageDirectoryPath();
    String safeDetails = sanitizeFileName(details);
    final fileName = '${id}_${safeDetails}_${time.millisecondsSinceEpoch}.png';
    final filePath = join(folderPath, fileName);

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    return filePath; // return path to store in DB
  }


  static Future<void> createRecordTables(sql.Database database) async {

    await database.execute("""
    CREATE TABLE AllTransactionRecords(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isReceived INTEGER NOT NULL,      
        details TEXT,        
        amt REAL NOT NULL,
        txndatetime TEXT NOT NULL,
        imageBase64 TEXT,
        categoryid INTEGER NOT NULL
      )
      """);
  }


  static Future<sql.Database> recordDb() async {
    if (_recordsDb != null) return _recordsDb!;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'recordsDb.db');   

    _recordsDb = await sql.openDatabase(
       path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createRecordTables(database);
      },      
    );
    return _recordsDb!;
  }
  

  static Future<Map<String, double>> getGoalTotals() async {
    final db = await SQLHelper.recordDb();

    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN isReceived = 1 AND categoryid = 3  THEN amt ELSE 0 END) AS totalReceived,
        SUM(CASE WHEN isReceived = 0 AND categoryid = 3 THEN amt ELSE 0 END) AS totalSpent
      FROM AllTransactionRecords
    ''');

    final row = result.first;

    return {
      'received': row['totalReceived'] != null ? (row['totalReceived'] as num).toDouble() : 0.0,
      'spent': row['totalSpent'] != null ? (row['totalSpent'] as num).toDouble() : 0.0,
    };
  }

    static Future<List<Map<String, dynamic>>> getExpenseByCategory() async {
      final db = await SQLHelper.recordDb(); // adjust to your DB instance
      return await db.rawQuery('''
        SELECT categoryid, SUM(amt) as total
        FROM AllTransactionRecords
        WHERE isReceived = 0
        GROUP BY categoryid
        ORDER BY id DESC
      ''');
    }

  static Future<Map<String, double>> getDashboardTotals() async {
   final db = await SQLHelper.recordDb();
   final billDb = await SQLHelper.billtransactionrecordsDb();

  final result = await db.rawQuery('''
    SELECT 
      SUM(CASE WHEN isReceived = 1 THEN amt ELSE 0 END) AS totalReceived,
      SUM(CASE WHEN isReceived = 0 THEN amt ELSE 0 END) AS totalSpent
    FROM AllTransactionRecords
  ''');

  final billResult = await billDb.rawQuery('''
    SELECT SUM(amt) AS totalBillsSpent FROM billTransactionRecords
  ''');

  final row = result.first;
  final billRow = billResult.first;

  double received = row['totalReceived'] != null ? (row['totalReceived'] as num).toDouble() : 0.0;
  double spent = row['totalSpent'] != null ? (row['totalSpent'] as num).toDouble() : 0.0;
  double billsSpent = billRow['totalBillsSpent'] != null ? (billRow['totalBillsSpent'] as num).toDouble() : 0.0;



  return {
    'received': received,
    'spent': spent + billsSpent,
  };
}
  static Future<List<Map<String, dynamic>>> getRecordsatIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final db = await SQLHelper.recordDb();
    final placeholders = List.filled(ids.length, '?').join(', ');
    final result = await db.query(
      'AllTransactionRecords', 
      where: 'id IN ($placeholders)',
      whereArgs: ids,
      orderBy: "id"
    );
    return result;
  }
  static Future<void> updateRecordImagePath(int id, String? newPath) async {
      final db = await SQLHelper.recordDb();
      await db.update(
        'AllTransactionRecords',
        {'imageBase64': newPath}, // You can also use `null` directly
        where: 'id = ?',
        whereArgs: [id],
      );
    }

 
  static Future<int> createRecord(
    int isReceived,
    String? details,
    double amt,
    String txndatetime,
    Uint8List? imageBytes,
    int categoryid) async {
    final db = await SQLHelper.recordDb();

    String? imagePath;
    if (imageBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'txn_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      String safeDetails = sanitizeFileName(details ?? '');
      final fileName = '${safeDetails}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = join(folder.path, fileName);
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      imagePath = path;
    }

    final data = {
      'isReceived': isReceived,
      'details': details,
      'amt': amt,
      'txndatetime': txndatetime,
      'imageBase64': imagePath,
      'categoryid': categoryid,
    };

    final id = await db.insert('AllTransactionRecords', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  
  static Future<List<Map<String, dynamic>>> getRecords() async {
    final db = await SQLHelper.recordDb();
    return db.query('AllTransactionRecords', orderBy: "id DESC",);
  }

  
  static Future<List<Map<String, dynamic>>> getRecord(int id) async {
    final db = await SQLHelper.recordDb();
    return db.query('AllTransactionRecords', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateRecord(
    int id,
    int isReceived,
    String? details,
    double amt,
    String txndatetime,
    Uint8List? newImageBytes,
    int categoryid,
  ) async {
    final db = await SQLHelper.recordDb();

    String? newImagePath;

    final existing = await db.query(
      'AllTransactionRecords',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (newImageBytes != null && existing.isNotEmpty) {
      final oldImagePath = existing.first['imageBase64'] as String?;
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
    }

    if (newImageBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'txn_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = '${details ?? ''}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = join(folder.path, fileName);
      final file = File(path);
      await file.writeAsBytes(newImageBytes);
      newImagePath = path;
    }

    final data = {
      'isReceived': isReceived,
      'details': details,
      'amt': amt,
      'txndatetime': txndatetime,
      'imageBase64': newImagePath ?? existing.first['imageBase64'],
      'categoryid': categoryid,
    };

    final result = await db.update(
      'AllTransactionRecords',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  static Future<void> deleteRecord(int id) async {
    final db = await SQLHelper.recordDb();

    try {
      // Get the image path for the record
      final existing = await db.query(
        "AllTransactionRecords",
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final imagePath = existing.first['imageBase64'] as String?;
        
        // Delete the image file if it exists
        if (imagePath != null) {
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
      }

      // Delete the record from the database
      await db.delete("AllTransactionRecords", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> cleanUpUnusedImageFiles() async {
    final db = await SQLHelper.recordDb();

    try {
      // Get the directory containing the saved images
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'txn_images'));

      if (!await folder.exists()) {
        return; 
      }

      final allFiles = folder.listSync().whereType<File>().toList();

      // Get all image paths stored in the database
      final records = await db.query('AllTransactionRecords', columns: ['imageBase64']);
      final usedPaths = records
          .map((record) => record['imageBase64'] as String?)
          .where((path) => path != null)
          .toSet();

      // Delete files not referenced in DB
      for (final file in allFiles) {
        if (!usedPaths.contains(file.path)) {
          await file.delete();
        }
      }

      debugPrint("Image cleanup complete. Unused files deleted.");
    } catch (e) {
      debugPrint("Error during image cleanup: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getRecordsBetweenDates(DateTime start, DateTime end) async {
    final db = await SQLHelper.recordDb();
    return await db.query(
      'AllTransactionRecords',
      where: 'txndatetime BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'id DESC',
    );
  }



  //BILL LOGIC STARTS HERE

  static Future<void> createBillTables(sql.Database database) async {   


    await database.execute("""
    CREATE TABLE BillRecords(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        curbillamt REAL NOT NULL,        
        billname TEXT NOT NULL,
        billdetails TEXT,
        frequency REAL NOT NULL,
        duedatetime TEXT NOT NULL,        
        data TEXT,
        isallPaid INTEGER NOT NULL
      )
      """);
  }

  static Future<sql.Database> billDb() async {
    if (_billsDb != null) return _billsDb!;
        final dir = await getApplicationDocumentsDirectory();
        final path = join(dir.path, 'billsDb.db');

    _billsDb = await sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createBillTables(database);
      },  
    );

    return _billsDb!;

  }


  // Create new item (journal)
  static Future<int> createBill(double curbillamt, String billname, String? billdetails, double frequency, String duedatetime,String? billdata) async {
    final db = await SQLHelper.billDb();

    Map<String, dynamic> data = {
        'curbillamt':curbillamt,
        'billname':billname,
        'billdetails': billdetails,
        'frequency': frequency,
        'duedatetime' : duedatetime,
        'data': billdata,
        'isallPaid':0,
      };
    final id = await db.insert('BillRecords', data,
    conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  
  static Future<List<Map<String, dynamic>>> getBills() async {
    final db = await SQLHelper.billDb();
    return db.query('BillRecords', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getBill(int id) async {
    final db = await SQLHelper.billDb();
    return db.query('BillRecords', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateBill(int id,
      double curbillamt,String billname, String? billdetails, double frequency, String duedatetime, String? billdata, int isallPaid) async {
    final db = await SQLHelper.billDb();    
    final data = {
      'curbillamt':curbillamt,
      'billname':billname,
      'billdetails': billdetails,
      'frequency': frequency,
      'duedatetime' : duedatetime,
      'data': billdata,
      'isallPaid':isallPaid,
    };

    final result =
    await db.update('BillRecords', data, where: "id = ?", whereArgs: [id]);
    return result;
  }


  static Future<int> updateBilldata(int id,
      int addid, double newCurAmt, String newduedatetime, int isallPaid) async {
        
    final db = await SQLHelper.billDb();    
    final tempitem = await db.query('BillRecords', where: 'id = ?', whereArgs: [id], limit: 1);

    String jsonString = tempitem.first['data'] as String;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<int> datalist = List<int>.from(jsonList);

    datalist.add(addid);

    final newdatastring = jsonEncode(datalist);

    int tid = await db.update(
    'BillRecords',
    {
      
      'curbillamt':newCurAmt,
      'duedatetime' : newduedatetime,
      'data': newdatastring,
      'isallPaid': isallPaid

    },
    where: 'id = ?',
    whereArgs: [id],
    );
    return tid;
  }

  static Future<void> removeTransactionIdFromBillData(int transactionId) async {
    final db = await SQLHelper.billDb();

    final bills = await db.query('BillRecords');

    for (final bill in bills) {
      final iddataStr = bill['data'] as String? ?? '[]';
      final List<int> idList = List<int>.from(jsonDecode(iddataStr));

      if (idList.contains(transactionId)) {
        idList.remove(transactionId);
        final updatedData = jsonEncode(idList);

        await db.update(
          'BillRecords',
          {'data': updatedData},
          where: 'id = ?',
          whereArgs: [bill['id']],
        );

        break;
      }
    }
  }

  // Delete
  static Future<void> deleteBill(int id) async {
    final db = await SQLHelper.billDb();
    try {
      await db.delete("BillRecords", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  //BillRecord LOGIC STARTS HERE

  static Future<void> createbilltransactionrecordsTables(sql.Database database) async {
  
    await database.execute("""
    CREATE TABLE billTransactionRecords(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  
        notes TEXT,
        amt REAL NOT NULL,
        txndatetime TEXT NOT NULL,
        duedatetime TEXT NOT NULL,        
        imageBase64 TEXT,
        billname TEXT NOT NULL
      )
      """);
  }
  

  static Future<sql.Database> billtransactionrecordsDb() async {
    if (_billtransactionrecordsDb != null) return _billtransactionrecordsDb!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'BillRecordsDb.db');   

    _billtransactionrecordsDb = await sql.openDatabase(
       path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createbilltransactionrecordsTables(database);
      }, 
    );
    return _billtransactionrecordsDb!;
  }

  static Future<int> createbilltransactionRecord(
    String? details,
    double amt,
    String txndatetime,
    String duedatetime,
    Uint8List? imageBytes,
    String billname) async {
    final db = await SQLHelper.billtransactionrecordsDb();

    String? imagePath;
    if (imageBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'bill_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = '${details ?? ''}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = join(folder.path, fileName);
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      imagePath = path;
    }

    final data = {
      'notes': details,
      'amt': amt,
      'txndatetime': txndatetime,
      'duedatetime': duedatetime,
      'imageBase64': imagePath,
      'billname': billname,
    };

    final id = await db.insert('billTransactionRecords', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getbillTransactionRecords() async {
    final db = await SQLHelper.billtransactionrecordsDb();
    return db.query('billTransactionRecords', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getbillTransactionRecordsatIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final db = await SQLHelper.billtransactionrecordsDb();
    final placeholders = List.filled(ids.length, '?').join(', ');
    final result = await db.query(
      'billTransactionRecords', 
      where: 'id IN ($placeholders)',
      whereArgs: ids,
      orderBy: "id"
    );
    return result;
  }


  static Future<List<Map<String, dynamic>>> getbillTransactionRecord(int id) async {
    final db = await SQLHelper.billtransactionrecordsDb();
    return db.query('billTransactionRecords', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<void> updateBillImagePath(int id, String? newPath) async {
    final db = await SQLHelper.billtransactionrecordsDb();
    await db.update(
      'billTransactionRecords',
      {'imageBase64': newPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updatebillTransactionRecord(
    int id,
    String? details,
    double amt,
    String txndatetime,
    String duedatetime,
    Uint8List? newImageBytes,
    String billname) async {

    final db = await SQLHelper.billtransactionrecordsDb();

    String? newImagePath;

    // Fetch existing image path
    final existing = await db.query(
      'billTransactionRecords',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    //delete old image if needed
    if (newImageBytes != null && existing.isNotEmpty) {
      final oldImagePath = existing.first['imageBase64'] as String?;
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
    }

    // Save new image (if provided)
    if (newImageBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'bill_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = '${details ?? ''}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = join(folder.path, fileName);
      final file = File(path);
      await file.writeAsBytes(newImageBytes);
      newImagePath = path;
    }

    // Prepare and update data
    final data = {
      'notes': details,
      'amt': amt,
      'txndatetime': txndatetime,
      'duedatetime': duedatetime,
      'imageBase64': newImagePath ?? existing.first['imageBase64'], // path (or null if no image)
      'billname': billname,
    };

    final result = await db.update(
      'billTransactionRecords',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  // Delete
  static Future<void> deletebillTransactionRecord(int id) async {
    final db = await SQLHelper.billtransactionrecordsDb();
    try {
      final existing = await db.query(
        "billTransactionRecords",
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final imagePath = existing.first['imageBase64'] as String?;
        if (imagePath != null) {
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
      }

      await db.delete("billTransactionRecords", where: "id = ?", whereArgs: [id]);

      // Also remove from BillRecords.data
      await removeTransactionIdFromBillData(id);

    } catch (err) {
      debugPrint("Something went wrong when deleting a bill transaction: $err");
    }
  }

  static Future<void> cleanUpUnusedBillTxnImageFiles() async {
    final db = await SQLHelper.billtransactionrecordsDb();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(join(dir.path, 'bill_images'));

      if (!await folder.exists()) return;

      final allFiles = folder.listSync().whereType<File>().toList();

      final records = await db.query('billTransactionRecords', columns: ['imageBase64']);
      final usedPaths = records
          .map((record) => record['imageBase64'] as String?)
          .where((path) => path != null)
          .toSet();

      for (final file in allFiles) {
        if (!usedPaths.contains(file.path)) {
          await file.delete();
        }
      }

      debugPrint("Bill transaction image cleanup complete.");
    } catch (e) {
      debugPrint("Error during bill image cleanup: $e");
    }
  }


  static Future<String?> getBillNameFromTransactionId(int transactionId) async {
    final db = await SQLHelper.billDb();

    final allBills = await db.query('BillRecords');

    for (final bill in allBills) {
      final iddataStr = bill['data'] as String? ?? '[]';
      final idList = List<int>.from(jsonDecode(iddataStr));

      if (idList.contains(transactionId)) {
        return bill['billname'] as String;
      }
    }

    return null; 
  }

  static Future<List<Map<String, dynamic>>> getOverdueBills() async {
    final db = await SQLHelper.billDb();
    final now = DateTime.now();

    return await db.query(
      'BillRecords',
      where: 'isallPaid = 0 AND duedatetime < ?',
      whereArgs: [now.toIso8601String()],
      orderBy: 'duedatetime ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> getBillsDueInNextTwoWeeks() async {
    final db = await SQLHelper.billDb();
    final now = DateTime.now();
    final twoWeeksLater = now.add(Duration(days: 14));

    return await db.query(
      'BillRecords',
      where: 'isallPaid = 0 AND duedatetime BETWEEN ? AND ?',
      whereArgs: [now.toIso8601String(), twoWeeksLater.toIso8601String()],
      orderBy: 'duedatetime ASC',
    );
  }


   //Category LOGIC STARTS HERE

  static Future<void> createCategoryTables(sql.Database database) async {
    
  
    await database.execute("""
    CREATE TABLE Recordcategories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  
        name TEXT NOT NULL,
        notes TEXT,
        iddata TEXT,
        isReceived INTEGER NOT NULL
      )
      """);      
  }

  static Future<sql.Database> categoryDb() async {
    if (_categoryDb != null) return _categoryDb!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'categoryDb.db');   

    _categoryDb = await sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createCategoryTables(database);
        await database.insert('Recordcategories', {
          'name': 'Others',
          'notes': 'All the unassigned transactions go here',
          'iddata': '[]',
          'isReceived': 2,
          },
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
        await database.insert('Recordcategories', {
          'name': 'Bills',
          'notes': 'All the bill transactions go here',
          'iddata': '[]',
          'isReceived': 3,
          },
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
        await database.insert('Recordcategories', {
          'name': 'Savings',
          'notes': 'Money saved from your goals',
          'iddata': '[]',
          'isReceived': 2,
          },
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
      },      
    );

    return _categoryDb!;
    
  }

  static Future<int> createcategory(String name,String? notes,String iddata, int isReceived) async {
    final db = await SQLHelper.categoryDb();
    
    final data = {
        'name': name,
        'notes': notes,
        'iddata': iddata,
        'isReceived':isReceived,
      };
    final id = await db.insert('Recordcategories', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all Records (journals)
  static Future<List<Map<String, dynamic>>> getallcategories() async {
    final db = await SQLHelper.categoryDb();
    return db.query('Recordcategories', orderBy: "id");
  }
  

  // Read a single item by id
  static Future<List<Map<String, dynamic>>> getcategoryatID(int id) async {
    final db = await SQLHelper.categoryDb();
    return db.query('Recordcategories', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updatecategory(int id,
    String name,String? notes,String iddata, int isReceived) async {
    final db = await SQLHelper.categoryDb();    
    final data = {
      'id': id,
      'name': name,
      'notes': notes, 
      'iddata': iddata,
      'isReceived':isReceived,
      
    };

    final result =
    await db.update('Recordcategories', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deletecategory(int id, int newconversionid) async {
    final db1 = await SQLHelper.categoryDb();
    final db2 = await SQLHelper.recordDb();
    final tmpcat = await SQLHelper.getcategoryatID(id);
    final cat = tmpcat[0];
    List<int> idList = List<int>.from(jsonDecode(cat['iddata'] as String));
    for (var item in idList) {
      await db2.update('AllTransactionRecords', {'categoryid': newconversionid}, where: "id = ?", whereArgs: [ item ]);
    }
    try {
      await db1.delete("Recordcategories", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }


  static Future<int> addCategorydata(int id,
      List<int> addid ) async {
        
    final db = await SQLHelper.categoryDb(); 
    final tempitem = await db.query('Recordcategories', where: 'id = ?', whereArgs: [id], limit: 1);

    String jsonString = (tempitem.first['iddata'] as String?) ?? '[]';
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<int> datalist = List<int>.from(jsonList);

    datalist+=addid;

    final newdatastring = jsonEncode(datalist);

    int tid = await db.update(
    'Recordcategories',
    {     
      'iddata': newdatastring,
    },
    where: 'id = ?',
    whereArgs: [id],
    );
    return tid;
  }

  static Future<int> removeIdListFromCategoryData(int categoryId, List<int> idsToRemove) async {
  final db = await SQLHelper.categoryDb();
  final tempItem = await db.query(
    'Recordcategories',
    where: 'id = ?',
    whereArgs: [categoryId],
    limit: 1,
  );

  if (tempItem.isEmpty) return 0;

  String jsonString = (tempItem.first['iddata'] as String?) ?? '[]';
  List<dynamic> jsonList = jsonDecode(jsonString);
  List<int> idList = List<int>.from(jsonList);

  // Remove each ID in idsToRemove from idList
  idList.removeWhere((id) => idsToRemove.contains(id));

  final updatedData = jsonEncode(idList);

  return await db.update(
    'Recordcategories',
    {
      'iddata': updatedData,
    },
    where: 'id = ?',
    whereArgs: [categoryId],
  );
}


  //todolist logic starts here

  static Future<void> createTodoTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE Todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT NOT NULL,
        isComplete INTEGER NOT NULL
      )
    """);
  }

  static Future<sql.Database> todoDb() async {
    if (_todoDb != null) return _todoDb!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'todoDb.db');

    _todoDb = await sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTodoTables(database);
      },
    );
    return _todoDb!;
  }

  static Future<int> createTodo(String item, int isComplete) async {
    final db = await SQLHelper.todoDb();
    final data = {
      'item': item,
      'isComplete': isComplete,
    };
    return await db.insert('Todos', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await SQLHelper.todoDb();
    return db.query('Todos', orderBy: 'id DESC');
  }

  static Future<int> updateTodoCompletion(int id, int isComplete) async {
  final db = await SQLHelper.todoDb();
  return await db.update(
    'Todos',
    {'isComplete': isComplete},
    where: 'id = ?',
    whereArgs: [id],
  );
}

  static Future<void> deleteTodo(int id) async {
    final db = await SQLHelper.todoDb();
    try {
      await db.delete('Todos', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting a ToDo: $err');
    }
  }  


  //APP DATA LOGIC STARTS HERE

  static Future<void> createAppDataTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE appData(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        currency TEXT NOT NULL,
        profile_pic_icon TEXT,
        isAppLockEnabled INTEGER NOT NULL,
        currentgoalamt REAL NOT NULL
      )
    """);
  }

 static Future<sql.Database> appDataDb() async {
  if (_appDataDb != null) return _appDataDb!;
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'appDataDb.db');

  _appDataDb = await sql.openDatabase(
    path,
    version: 1,
    onCreate: (sql.Database database, int version) async {
      await createAppDataTables(database);
    },
  );
  return _appDataDb!;
}


  static Future<int> storeAppData(
      String username, 
      String currency,
      String profilePicIcon,
      int isAppLockEnabled,
      double currentgoalamt

    ) async {
    final db = await SQLHelper.appDataDb();
    final data = {
      'username': username,
      'currency': currency,
      'profile_pic_icon': profilePicIcon,
      'isAppLockEnabled': isAppLockEnabled,
      'currentgoalamt': currentgoalamt,      
      
    };
    return await db.insert('appData', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getappData() async {
    final db = await SQLHelper.appDataDb();
    return db.query('appData', orderBy: 'id ASC');
  }



  static Future<int> updateGoalAmt(int id, double newgoalAmt) async {
    final db = await SQLHelper.appDataDb();
    return await db.update(
      'appData',
      {'currentgoalamt': newgoalAmt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<int> updateAppLockStatus(int id, int newapplockstatus) async {
    final db = await SQLHelper.appDataDb();
    return await db.update(
      'appData',
      {'isAppLockEnabled': newapplockstatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<int> updateAppCurrency(int id, String currency) async {
    final db = await SQLHelper.appDataDb();
    return await db.update(
      'appData',
      {'currency': currency},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateAppUsernameAvatar(int id, String username, String avatar) async {
    final db = await SQLHelper.appDataDb();
    return await db.update(
      'appData',
      {
        'username': username,
        'profile_pic_icon': avatar
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  static Future<void> closeAllDatabases() async {
    try {
      await _appDataDb?.close();
      await _recordsDb?.close();
      await _categoryDb?.close();
      await _billsDb?.close();
      await _billtransactionrecordsDb?.close();
      await _todoDb?.close();
    } catch (e) {
      debugPrint('Error closing DBs: $e');
    }
    _appDataDb = null;
    _recordsDb = null;
    _categoryDb = null;
    _billsDb = null;
    _billtransactionrecordsDb = null;
    _todoDb = null;
  }
}