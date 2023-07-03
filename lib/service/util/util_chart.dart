import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../const/model/model_daily_check_history.dart';
import '../../my_app.dart';
import 'dart:math' as math;

BarChartData getLineChartData(List<ModelDailyCheckHistory> listModelDailyCheckHistory) {
  MyApp.logger.d("getLineChartData listModelDailyCheckHistory 갯수 : ${listModelDailyCheckHistory.length}");

  int maxY = 0;
  for (var element in listModelDailyCheckHistory) {
    if (element.userCheckHistoryCount > maxY) {
      maxY = element.userCheckHistoryCount;
    }
  }

  List<BarChartGroupData> listBarChartGroupData = [];

  for (int i = 0; i < listModelDailyCheckHistory.length; i++) {
    listBarChartGroupData.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: listModelDailyCheckHistory[i].userCheckHistoryCount.toDouble(),
            color: Colors.green,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(4),topRight: Radius.circular(4)),
            width: 20,
            //gradient: _barsGradient,
          )
        ],
      ),
    );
  }

  int maxYForLabel = (maxY * 1.2).toInt();
  int intervalForLabel = max(maxYForLabel ~/ 5, 2);

  /* MyApp.logger.d("listModelDailyCheckHistory[i].userCheckHistoryCount .toDouble() : ${[
    ...listModelDailyCheckHistory.map((e) => e.userCheckHistoryCount.toDouble()).toList()
  ]}");*/

  return BarChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: intervalForLabel.toDouble(),
      //verticalInterval: intervalForLabel.toDouble(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.black.withOpacity(0.8),
          strokeWidth: 0.8,
        );
      },
/*      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Colors.black,
          strokeWidth: 1,
        );
      },*/
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: intervalForLabel.toDouble(),
          getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text('${value.toInt()}${value.toInt() == 0 ? '' : ''}')),
          reservedSize: 10,
        ),
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

            return Text(
              dayOnly,
              style: TextStyle(color: color, fontSize: 11),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: intervalForLabel.toDouble(),
          getTitlesWidget: (value, meta) => Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text('${value.toInt()}${value.toInt() == 0 ? '' : ''}')),
          ),
          reservedSize: 10,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minY: 0,
    maxY: maxYForLabel.toDouble(),
    barGroups: listBarChartGroupData,
    barTouchData: BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.greenAccent.withOpacity(0.8),
        tooltipPadding: const EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
        tooltipMargin: 4,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          int index = group.x.toInt();
          String text;
          //예외 처리용
          if (index < 0 || index >= listModelDailyCheckHistory.length) {
            text = '';
          } else {
            String dayOnly = listModelDailyCheckHistory[index].dateDisplay;
            text = '$dayOnly\n${rod.toY.toInt().toString()}건';
          }

          return BarTooltipItem(
            text,
            const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    ),
  );
}
