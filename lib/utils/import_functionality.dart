import 'dart:io';
import 'package:FiniZen/database/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:path/path.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> importAndReplaceDatabases(BuildContext context) async {
  final appData = await SQLHelper.getappData();
  final hasData = appData.isNotEmpty;
  final expectedDbFiles = {
    'recordsDb.db',
    'billsDb.db',
    'BillRecordsDb.db',
    'categoryDb.db',
    'todoDb.db',
  };

  final expectedImageDirs = {
    'txn_images/',
    'bill_images/',
  };
  
  if (hasData && appData[0]['isAppLockEnabled'] == 1) {
    AppLock.of(context)?.disable();
  }
   
  // Request permission
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage permission denied')),
    );
    return;
  }
  await SQLHelper.closeAllDatabases();
  try {
    // Let the user pick a zip file
    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      fileExtensionsFilter: ['zip'],
      allowEditing: false,
    );

    final selectedPath = await FlutterFileDialog.pickFile(params: params);
    if (selectedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import canceled by user')),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final zipFile = File(selectedPath);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final archiveFileNames = archive.map((f) => f.name).toSet();

    final hasRelevantContent = archiveFileNames.any((name) =>
      expectedDbFiles.contains(name) || 
      expectedImageDirs.any((dir) => name.startsWith(dir))
    );

    if (!hasRelevantContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ZIP does not contain any known DB or image folders')),
      );
      return;
    }

    for (final file in archive) {
      final filePath = join(appDir.path, file.name);
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        final dir = Directory(filePath);
        await dir.create(recursive: true);
      }
    }
    


    if (hasData && appData[0]['isAppLockEnabled'] == 1) {
      AppLock.of(context)?.enable();
    }
    
    SQLHelper.initAllDatabases();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data import successful')),
    );


    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Import failed: $e')),
    );
  }
  
}
