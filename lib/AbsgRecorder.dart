import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

//Read and write files
//https://docs.flutter.dev/cookbook/persistence/reading-writing-files
class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    print(directory.path);

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeStr(String filename, String str) async {
    final path = await _localPath;
    final file = File("$path/$filename");
    // Write the file
    return file.writeAsString(str);
  }
}

class AbsgRecorder extends StatefulWidget {
  const AbsgRecorder({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  State<AbsgRecorder> createState() => _AbsgRecorderState();
}

class _AbsgRecorderState extends State<AbsgRecorder> {
  List<double> time = [];
  var data = [];
  var timer;

  bool _recording = false;

  void _toggleRecord() {
    if (!_recording) {
      print("start recording");
      time = [];
      data = [];
      timer = Timer.periodic(const Duration(milliseconds: 10), ((timer) {
        time.add(_clock.toDouble() / 100);
        var tmp = [_absg, _ax, _ay, _az];
        data.add(tmp);
        _clock++;
      }));
    } else {
      print("stop recording");
      timer.cancel();
    }

    _recording = !_recording;
  }

  void _outportCSV() {
    print("outputCSV");

    String outputString = "";

    for (var ar in data) {
      var col = 0;
      for (var val in ar) {
        outputString += val.toString();
        if (col != 0 && col != ar.length - 1) {
          outputString += ",";
        }
        col++;
      }
      outputString += "\n";
    }

    print(time.length);

    final directory = getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final suffix = ".csv";
    final filename = sprintf("data_%d%d%d%d%d%d%s", [
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      suffix
    ]);
    widget.storage.writeStr(filename, outputString);
  }

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
    return Row(children: [
      const SizedBox(
        width: 10,
      ),
      OutlinedButton(
          onPressed: () {
            _toggleRecord();
          },
          child: const Text("Record")),
      const SizedBox(
        width: 10,
      ),
      OutlinedButton(
          onPressed: () {
            _outportCSV();
          },
          child: const Text("Output CSV"))
    ]);
  }
}
