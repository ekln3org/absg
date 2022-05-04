import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

class LogListView extends StatefulWidget {
  const LogListView({Key? key}) : super(key: key);

  @override
  State<LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends State<LogListView> {
  List<FileSystemEntity> entities = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    print(directory.path);

    return directory.path;
  }

  Future<List<FileSystemEntity>> get _FilesListInDocument async {
    final List<FileSystemEntity> files = [];

    // Get the system temp directory.
    var directory = await getApplicationDocumentsDirectory();
    //var systemTempDir = Directory.systemTemp;
    var systemTempDir = Directory(directory.path);
    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    await for (var entity
        in systemTempDir.list(recursive: true, followLinks: false)) {
      if (await FileSystemEntity.isFile(entity.path)) {
        files.add(entity);
      }
      //print(entity.path);
    }
    return files;
  }

  @override
  void initState() {
    RefreshList();
    super.initState();
  }

  void _onPressed() {
    print("HEY");
  }

  Widget _itemBuilder(BuildContext context, int index) {
    String filename = "dd";
    FileSystemEntity entity;
    print("entities.length:" + (entities.length).toString());
    if (entities.length != 0) {
      entity = entities[index];
      filename = Path.basename(entity.path);
      print("filname:" + filename);
    }

    print("return Container");
    return Container(
      height: 70,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              entities.length == 0
                  ? const Text("There is no records yet.")
                  : Text(filename),
              Container(
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Icon(Icons.drive_file_rename_outline),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Icon(Icons.open_in_browser),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Icon(Icons.share),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void RefreshList() async {
    entities = await _FilesListInDocument;
    print(entities.length);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: RefreshList,
          child: const Text("Refresh"),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
              itemCount: entities.length == 0 ? 1 : entities.length,
              reverse: false,
              itemBuilder: _itemBuilder),
        )
      ],
    );

    // return Container(
    //     child: Column(
    //   children: [
    //     const Text("LogListView"),
    //     ElevatedButton(onPressed: _onPressed, child: const Text("HEY")),
    //   ],
    // ));
  }
}
