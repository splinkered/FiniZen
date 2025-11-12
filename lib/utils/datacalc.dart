
import 'package:FiniZen/providers/dashboarddbprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


List<double> getAllData (BuildContext context){
  double tempSpent = 0;
  double tempReceived = 0;
  double tempOverall = 0;
  Provider.of<RecordsProvider>(context, listen: false).freshRecords();
  final data = Provider.of<RecordsProvider>(context, listen: false).records;

  for (var item in data) {
    item['isReceived'] == 1 ? tempReceived += item['amt'] : tempSpent += item['amt'];
  }
  tempOverall = tempReceived - tempSpent;

  return [tempSpent, tempReceived, tempOverall];


}