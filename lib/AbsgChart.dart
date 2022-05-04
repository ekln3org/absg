import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class MyAbsgCharts extends StatefulWidget {
  const MyAbsgCharts({Key? key}) : super(key: key);

  @override
  State<MyAbsgCharts> createState() => _MyAbsgChartsState();
}

class _MyAbsgChartsState extends State<MyAbsgCharts> {
  int displayIndex = 0;

  final List<Widget> _charts = [
    const MyAbsgChart(),
    const MyAbsgChart2(),
  ];

  void _onPageChanged(index) {
    setState(() {
      displayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: PageController(),
      children: _charts,
      onPageChanged: _onPageChanged,
    );
  }
}

class MyAbsgChart extends StatefulWidget {
  const MyAbsgChart({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart> createState() => _MyAbsgChartState();
}

class _MyAbsgChartState extends State<MyAbsgChart> {
  double _g = 9.8;

  int _clock = 0;

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _absa = 0;
  double _absg = 0;

  @override
  void initState() {
    Timer.periodic(
        Duration(milliseconds: 10), (timer) => setState(() => _clock++));
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
      _gx = _ax / _g;
      _gy = _ay / _g;
      _gz = _az / _g;
      _absa = sqrt(pow(_ax, 2) + pow(_ay, 2));
      _absg = sqrt(pow(_gx, 2) + pow(_gy, 2));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
          maxY: 2,
          minY: -2,
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
              BarChartRodData(toY: _absa, width: 15, colors: [Colors.red]),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _ax, width: 15),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _ay, width: 15),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _az, width: 15),
            ]),
          ]),
    );
  }
}

class MyAbsgChart2 extends StatefulWidget {
  const MyAbsgChart2({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart2> createState() => _MyAbsgChartState2();
}

class _MyAbsgChartState2 extends State<MyAbsgChart2> {
  double _g = 9.8;

  int _clock = 0;

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _absa = 0;
  double _absg = 0;
  List<ScatterSpot> _spots = [];

  ScatterSpot retSpot(x, y, z) {
    return ScatterSpot(x, y,
        radius: 5, //z * 100 + 10 > 10 ? z * 100 + 10 : 3,
        color: Color.fromRGBO(
            (255 - 255 * x).toInt(), (19).toInt(), (255 * y).toInt(), 0.8));
  }

  void _onTimer(timer) {
    if (_spots.length > 10) {
      _spots.removeAt(0);
    }
    ScatterSpot spot = retSpot(_gx, _gy, _gz);
    _spots.add(spot);

    setState(() {
      _clock++;
    });
  }

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 1), _onTimer);
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
      _gx = _ax / _g;
      _gy = _ay / _g;
      _gz = _az / _g;
      _absa = sqrt(pow(_ax, 2) + pow(_ay, 2));
      _absg = sqrt(pow(_gx, 2) + pow(_gy, 2));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: _spots,
        minX: -2,
        maxX: 2,
        minY: -2,
        maxY: 2,
        borderData: FlBorderData(
          show: true,
        ),
        gridData: FlGridData(
          show: true,
        ),
        titlesData: FlTitlesData(
          show: false,
        ),
        scatterTouchData: ScatterTouchData(
          enabled: false,
        ),
      ),
      // swapAnimationDuration: const Duration(milliseconds: 60),
      // swapAnimationCurve: Curves.fastOutSlowIn,
    );
  }
}
