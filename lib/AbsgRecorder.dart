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
        double time_ = _clock.toDouble() / 100;
        time.add(time_);
        var tmp = [time_, _absg, _gx, _gy, _gz];
        data.add(tmp);
        _clock++;
      }));
    } else {
      print("stop recording");
      timer.cancel();

      _outputCSV();
    }

    _recording = !_recording;
    setState(() {});
  }

  void _outputCSV() {
    print("outputCSV");

    if (data.isEmpty) {
      print("data is empty. return");

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please record first.')));

      return;
    }

    String outputString = "";

    outputString += "time,absg,gx,gy,gz\n";

    for (var ar in data) {
      var col = 0;
      for (var val in ar) {
        outputString += val.toString();
        if (col != ar.length - 1) {
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
    final filename = sprintf("data_%s%s%s%s%s%s%s", [
      now.year,
      now.month.toString().padLeft(2, "0"),
      now.day.toString().padLeft(2, "0"),
      now.hour.toString().padLeft(2, "0"),
      now.minute.toString().padLeft(2, "0"),
      now.second.toString().padLeft(2, "0"),
      suffix
    ]);
    widget.storage.writeStr(filename, outputString);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 800), content: Text('$filename')));
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
    return SizedBox(
      height: 10,
      width: double.infinity,
      child: OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                _recording ? Colors.red : Colors.white)),
        onPressed: () {
          _toggleRecord();
        },
        child: Text(
          _recording
              ? "Recording... Tap here to stop recording."
              : "Start new record",
          style: TextStyle(color: _recording ? Colors.white : Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
