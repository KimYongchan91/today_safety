import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../const/model/model_daily_check_history.dart';
import '../../my_app.dart';
import 'dart:math' as math;

BarChartData getLineChartData(List<ModelDailyCheckHistory> listModelDailyCheckHistory) {

  MyApp.logger.d("getLineChartData listModelDailyCheckHistory 갯수 : ${listModelDailyCheckHistory.length}");

  List<BarChartGroupData> listBarChartGroupData = [];

  for (int i = 0; i < listModelDailyCheckHistory.length; i++) {
    listBarChartGroupData.add(BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: listModelDailyCheckHistory[i].userCheckHistoryCount.toDouble(),
          color: Colors.green,
          borderRadius: BorderRadius.zero,
          width: 12,
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
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            //예외 처리용
            if (index < 0 || index >= listModelDailyCheckHistory.length) {
              return Container();
            }

            String dayOnly = listModelDailyCheckHistory[index].dateDisplay.split("-").last;
            if (dayOnly.length == 2 && dayOnly[0] == '0') {
              dayOnly = dayOnly[1];
            }

            Color color = Colors.black;
            if (listModelDailyCheckHistory[index].dateWeek == 6) {
              color = Colors.blueAccent;
            } else if (listModelDailyCheckHistory[index].dateWeek == 7) {
              color = Colors.redAccent;
            }

            return Transform.rotate(
              angle : 0,
              //angle: -math.pi / 2,
              child: Text(
                '$dayOnly',
                style: TextStyle(color: color,fontSize: 9),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
          reservedSize: 20,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minY: 0,
    maxY: maxY.toDouble(),
    barGroups: listBarChartGroupData,
  );
}
