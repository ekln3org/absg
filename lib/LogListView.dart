import 'package:flutter/material.dart';

class LogListView extends StatefulWidget {
  const LogListView({Key? key}) : super(key: key);

  @override
  State<LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends State<LogListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("LogListView"),
    );
  }
}
