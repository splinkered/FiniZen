// Market Share Analysis Example - Live Customization

import 'package:flutter/material.dart';
import 'package:material_charts/material_charts.dart';


class GoalProgressChart extends StatelessWidget {
  final double completionPercentage;
  const GoalProgressChart({super.key, required this.completionPercentage});

  @override
  Widget build(BuildContext context) {    
    return  MaterialChartHollowSemiCircle(
          percentage: completionPercentage,
          size: 180,
          hollowRadius: 0.7,
          style: ChartStyle(
            legendStyle: const TextStyle(overflow: TextOverflow.ellipsis),
            activeColor: completionPercentage >= 80 
                ? Colors.green 
                : completionPercentage >= 50 
                    ? Colors.orange 
                    : Colors.red,
            percentageStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            legendFormatter: (type, value) {
              return type == 'Active' 
                  ? '${value.toInt()}%'
                  : '${value.toInt()}%';
            },
          ),
        );
  }
}
