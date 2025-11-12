import 'dart:io';
import 'package:FiniZen/database/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

Future<void> exportFullDataAsZip(BuildContext context) async {
  try {
    final appData = await SQLHelper.getappData();
    final hasData = appData.isNotEmpty;
    if (hasData && appData[0]['isAppLockEnabled'] == 1) {
      AppLock.of(context)?.disable();
    }
   
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory(join(tempDir.path, 'full_export'));

    if (exportDir.existsSync()) {
      await exportDir.delete(recursive: true);
    }
    await exportDir.create();

    final dbDefinitions = <String, List<String>>{
      'recordsDb.db': ['AllTransactionRecords'],
      'billsDb.db': ['BillRecords'],
      'BillRecordsDb.db': ['billTransactionRecords'],
      'categoryDb.db': ['Recordcategories'],
      'todoDb.db': ['Todos'],
    };

    for (final entry in dbDefinitions.entries) {
      final dbName = entry.key;
      final tables = entry.value;
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, dbName);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        continue;
      }

      final db = await openDatabase(dbPath);
      final dbExportDir = Directory(join(exportDir.path, dbName.replaceAll('.db', '')));
      await dbExportDir.create();

      final excel = Excel.createExcel();
      
      for (String table in tables) {
        try {
          final data = await db.rawQuery('SELECT * FROM $table');
          
          if (data.isEmpty) continue;

          final sheet = excel[table];
          final headers = data.first.keys.toList();
          sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

          for (final row in data) {
            final rowValues = headers.map((k) {
              final value = row[k];
              return TextCellValue(value?.toString() ?? '');
            }).toList();
            sheet.appendRow(rowValues);
          }
          excel.delete('Sheet1');
        } catch (e) {
          //print('Skipping table $table in $dbName due to error: $e');
        }
      }

      // Write one Excel file per DB
      final fileBytes = excel.encode();
      final file = File(join(dbExportDir.path, '${dbName.replaceAll('.db', '')}.xlsx'));
      await file.writeAsBytes(fileBytes!);


      await db.close();
    }

    // Copy txn_images and bill_images
    final appDocDir = await getApplicationDocumentsDirectory();

    final txnImagesDir = Directory(join(appDocDir.path, 'txn_images'));
    final billImagesDir = Directory(join(appDocDir.path, 'bill_images'));

    final tempTxnDir = Directory(join(exportDir.path, 'txn_images'));
    final tempBillDir = Directory(join(exportDir.path, 'bill_images'));

    if (txnImagesDir.existsSync()) {
      await tempTxnDir.create(recursive: true);
      await for (final file in txnImagesDir.list()) {
        if (file is File) {
          await file.copy(join(tempTxnDir.path, basename(file.path)));
        }
      }
    }

    if (billImagesDir.existsSync()) {
      await tempBillDir.create(recursive: true);
      await for (final file in billImagesDir.list()) {
        if (file is File) {
          await file.copy(join(tempBillDir.path, basename(file.path)));
        }
      }
    }

    // Create ZIP
    final zipFilePath = join(tempDir.path, 'full_export.zip');
    final encoder = ZipFileEncoder();
    encoder.create(zipFilePath);
    encoder.addDirectory(exportDir);
    encoder.close();

    // Prompt to save ZIP
    final zipFile = File(zipFilePath);
    final params = SaveFileDialogParams(sourceFilePath: zipFile.path);
    await FlutterFileDialog.saveFile(params: params);
    if (hasData && appData[0]['isAppLockEnabled'] == 1) {
      AppLock.of(context)?.enable();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export complete.")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export failed: $e")));
  }
}
