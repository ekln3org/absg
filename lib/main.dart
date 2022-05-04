import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:absg/AbsgChart.dart';
import 'package:absg/LogListView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'absg',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _displayIndex = 0;

  List<Widget> _NavigationPages = [
    MyAbsgCharts(
      sensorData: SensorData(),
    ),
    LogListView(),
    CustomPage(),
  ];

  void _onTapBottomNavigationBar(index) {
    setState(() {
      _displayIndex = index;
    });
  }

  void _outportCSV({Key? key}) {
    print("pushed outport CSV button");
  }

  void _toggleRecord() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('absg'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: _NavigationPages[_displayIndex],
      )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.border_all),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: _displayIndex,
        onTap: _onTapBottomNavigationBar,
      ),
    );
  }
}

class CustomPage extends StatelessWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
