import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../const/model/model_daily_check_history.dart';
import '../../my_app.dart';

BarChartData getLineChartData(List<ModelDailyCheckHistory> listModelDailyCheckHistory) {
  List<BarChartGroupData> listBarChartGroupData = [];

  for (int i = 0; i < listModelDailyCheckHistory.length; i++) {
    listBarChartGroupData.add(BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: listModelDailyCheckHistory[i].userCheckHistoryCount.toDouble(),
          //gradient: _barsGradient,
        )
      ],
      //showingTooltipIndicators: [0],
    ));
  }

  int maxY = 0;
  for (var element in listModelDailyCheckHistory) {
    if (element.userCheckHistoryCount > maxY) {
      maxY = element.userCheckHistoryCount;
    }
  }

 /* MyApp.logger.d("listModelDailyCheckHistory[i].userCheckHistoryCount .toDouble() : ${[
    ...listModelDailyCheckHistory.map((e) => e.userCheckHistoryCount.toDouble()).toList()
  ]}");*/

  return BarChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Colors.black,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Colors.black,
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta){
            return Text('');

            if(value.toInt() ==0){
              return Text('');
            }

            //if(value.toInt() == )
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) => Text(value.toString()),
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minY: 0,
    maxY: maxY.toDouble(),
    barGroups:listBarChartGroupData,
  );
}
