import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class MyChart extends StatelessWidget {
  const MyChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: 10, width: 15),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: 9, width: 15),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: 4, width: 15),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: 2, width: 15),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(toY: 13, width: 15),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(toY: 17, width: 15),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(toY: 19, width: 15),
            ]),
            BarChartGroupData(x: 8, barRods: [
              BarChartRodData(toY: 21, width: 15),
            ]),
          ]),
    );
  }
}

class Clock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ClockState();
  }
}

class _ClockState extends State<Clock> {
  int _clock = 0;

  int get clock => _clock;

  double _g = 9.8;

  double _ax = 0;
  double _ay = 0;
  double _absg = 0;

  void refreshGraph() {}

  @override
  void initState() {
//    Timer.periodic(
    //      Duration(milliseconds: 10), (timer) => setState(() => _clock++));
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _ax = event.x;
        _ay = event.y;
        _absg = sqrt(pow(_ax, 2) + pow(_ay, 2)) / _g;
      });
      //setState
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_absg.toString()),
        Container(
          height: 10,
          width: _absg * 10,
          color: Colors.black,
        ),
        BarChart(
          BarChartData(
              borderData: FlBorderData(
                  border: const Border(
                top: BorderSide.none,
                right: BorderSide.none,
                left: BorderSide(width: 1),
                bottom: BorderSide(width: 1),
              )),
              groupsSpace: 1,
              barGroups: [
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: 10, width: 15),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(toY: 9, width: 15),
                ]),
                BarChartGroupData(x: 3, barRods: [
                  BarChartRodData(toY: 4, width: 15),
                ]),
                BarChartGroupData(x: 4, barRods: [
                  BarChartRodData(toY: 2, width: 15),
                ]),
                BarChartGroupData(x: 5, barRods: [
                  BarChartRodData(toY: 13, width: 15),
                ]),
                BarChartGroupData(x: 6, barRods: [
                  BarChartRodData(toY: 17, width: 15),
                ]),
                BarChartGroupData(x: 7, barRods: [
                  BarChartRodData(toY: 19, width: 15),
                ]),
                BarChartGroupData(x: 8, barRods: [
                  BarChartRodData(toY: 21, width: 15),
                ]),
              ]),
        ),
      ],
    );
  }
}
