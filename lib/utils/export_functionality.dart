import 'dart:io';
import 'package:FiniZen/database/db_manager.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

Future<void> exportAllDatabases(BuildContext context) async {
  final appData = await SQLHelper.getappData();
  final hasData = appData.isNotEmpty;
  
  if (hasData && appData[0]['isAppLockEnabled'] == 1) {
    AppLock.of(context)?.disable();
  }
  final appDir = await getApplicationDocumentsDirectory();
  final tempZipPath = join(appDir.path, 'all_data_export.zip');

  final dbFiles = [
    'recordsDb.db',
    'billsDb.db',
    'BillRecordsDb.db',
    'categoryDb.db',
    'todoDb.db',
  ];

  final imageDirs = [
    'txn_images',
    'bill_images',
  ];

  final encoder = ZipFileEncoder();
  encoder.create(tempZipPath);

  for (final dbName in dbFiles) {
    final dbPath = join(appDir.path, dbName);
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    }
  }

  for (final folderName in imageDirs) {
    final dirPath = join(appDir.path, folderName);
    final directory = Directory(dirPath);
    if (await directory.exists()) {
      encoder.addDirectory(directory);
    }
  }

  encoder.close();

  final status = await Permission.storage.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage permission denied')),
    );
    return;
  }

  final tempZipFile = File(tempZipPath);
  if (!await tempZipFile.exists()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export failed: Zip file missing')),
    );
    return;
  }

  try {
    final params = SaveFileDialogParams(
      sourceFilePath: tempZipFile.path,
      fileName: 'all_data_export.zip',
    );

    final savedPath = await FlutterFileDialog.saveFile(params: params);

    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to: $savedPath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export canceled by user')),
      );
    }
    if (hasData && appData[0]['isAppLockEnabled'] == 1) {
    AppLock.of(context)?.enable();
  }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $e')),
    );
  }
}