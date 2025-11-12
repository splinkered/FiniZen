// Market Share Analysis Example - Live Customization

import 'dart:convert';

import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/providers/expense_category_provider.dart';
import 'package:FiniZen/providers/income_category_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_charts/material_charts.dart';
import 'package:provider/provider.dart';



class SummaryPieChart extends StatefulWidget {
  final bool isExpenseChart;
  const SummaryPieChart({super.key, required this.isExpenseChart});

  @override
  State<SummaryPieChart> createState() => _SummaryPieChartState();
}

class _SummaryPieChartState extends State<SummaryPieChart> {
  final _data = <PieChartData>[];
  double valcheck=0;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  

  void _refreshCategories() async {
    
    _data.clear();   
    final jrdata = await SQLHelper.getallcategories();
    if(widget.isExpenseChart){
    _categories = jrdata.where((item)=> (item['isReceived'] == 0 || item['isReceived'] == 2 ||item['isReceived'] == 3)).toList();
      for (var item in _categories) {
        
        
        if(item['isReceived']==2){
          List<dynamic> tmplst = jsonDecode(item['iddata']);
          List<int> idList = List<int>.from(tmplst);
          double otherAmt = 0;
          final tempMixedRecords = await SQLHelper.getRecordsatIds(idList);
          for (var record in tempMixedRecords) {
            if(record['isReceived'] == 0){
              otherAmt += record['amt'] is int ? record['amt'].toDouble() : record['amt'] as double;
            }
          }
          if (otherAmt.isNaN || otherAmt <= 0) continue;
          _data.add(
          
          PieChartData(
            value: otherAmt,
            label: item['name'],
          ));
        } else if(item['isReceived']==3){
          List<dynamic> tmplst = jsonDecode(item['iddata']);
          List<int> idList = List<int>.from(tmplst);
          double billAmt = 0;
          final tempRecords = await SQLHelper.getbillTransactionRecordsatIds(idList);

          for (var record in tempRecords) {
              billAmt += record['amt'] as double;
          }
          if (billAmt.isNaN || billAmt <= 0) continue;
          _data.add(
          PieChartData(
            value: billAmt,
            label: item['name'],
          ));
        }
        else if(item['isReceived']==0){
          List<dynamic> tmplst = jsonDecode(item['iddata']);
          List<int> idList = List<int>.from(tmplst);

          double categoryAmt = 0;
          final tempNormaldRecords = await SQLHelper.getRecordsatIds(idList);
          for (var record in tempNormaldRecords) {            
              categoryAmt += record['amt'];
           
          }
          if (categoryAmt.isNaN || categoryAmt <= 0) continue;
          _data.add(
          PieChartData(
            value: categoryAmt,
            label: item['name'],
          ));
        }
    }
    }else if(widget.isExpenseChart == false){
      
        _categories = jrdata.where((item)=> (item['isReceived'] == 1 || item['isReceived'] == 2 ||item['isReceived'] == 3)).toList();
        for (var item in _categories) {
          
          
          if(item['isReceived']==2){
            List<dynamic> tmplst = jsonDecode(item['iddata']);
            List<int> idList = List<int>.from(tmplst);
            double otherAmt = 0;
            final tempMixedRecords = await SQLHelper.getRecordsatIds(idList);
            for (var record in tempMixedRecords) {
              if(record['isReceived'] == 1){
                otherAmt += record['amt'] is int ? record['amt'].toDouble() : record['amt'] as double;
              }
            }
            if (otherAmt.isNaN || otherAmt <= 0) continue;
            _data.add(
            
            PieChartData(
              value: otherAmt,
              label: item['name'],
            ));
          } 
          else if(item['isReceived']==1){
            List<dynamic> tmplst = jsonDecode(item['iddata']);
            List<int> idList = List<int>.from(tmplst);

            double categoryAmt = 0;
            final tempNormaldRecords = await SQLHelper.getRecordsatIds(idList);
            for (var record in tempNormaldRecords) {            
                categoryAmt += record['amt'];
            
            }
            if (categoryAmt.isNaN || categoryAmt <= 0) continue;
            _data.add(
            PieChartData(
              value: categoryAmt,
              label: item['name'],
            ));
          }
      }


    }
    for (var item in _data) {
      valcheck+=item.value;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.isExpenseChart){
        if (!mounted) return;
        final provider = Provider.of<ExpenseCategoryProvider>(context, listen: false);
        provider.clearCategories();
        for (var item in _data) {
          provider.addCategory(item.label, item.value);
        }      
     } else if(!widget.isExpenseChart){
        if (!mounted) return;
        final provider = Provider.of<IncomeCategoryProvider>(context, listen: false);
        provider.clearCategories();
        for (var item in _data) {
          provider.addCategory(item.label, item.value);
        }
     }
    });
    
  }


  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  @override
  void dispose() {   
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {    
    return _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
     : valcheck==0 ? Center(child: Text("No data recorded yet!"),) : SizedBox(
       width: MediaQuery.of(context).size.width * 0.9,
       child: MaterialPieChart(
         
         data: _data,
         width: MediaQuery.of(context).size.width * 0.6,
         height: MediaQuery.of(context).size.width * 0.6,
         minSizePercent: 0.0,
         
         chartRadius: 120,
         style: PieChartStyle(
           //defaultColors: [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal],
           backgroundColor: Colors.transparent,
           
           startAngle: -90.0,
           holeRadius: 4.0,
           animationDuration: Duration(milliseconds: 2000),
           animationCurve: Curves.easeOutCubic,
           labelOffset: 0,
           showLabels:true, 
           showValues: false,    
           showLegend: false,
           showConnectorLines: true,
           connectorLineColor: Colors.black54,
           connectorLineStrokeWidth: 1.0,
           chartAlignment: ChartAlignment.center,
           legendPosition: PieChartLegendPosition.bottom,
           labelStyle: TextStyle(
        color: Colors.black45,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.fade
           ),
           valueStyle: TextStyle(
        color: Colors.black26,
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
           ),
           
         ),
         interactive:false,
       
         showLabelOnlyOnHover: false,
         padding: EdgeInsets.all(24.0),
         onAnimationComplete: () {
           //print('Market Share Analysis animation completed!');
         },
       ),
     );
  }
}
