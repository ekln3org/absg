import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shake/shake.dart';
import 'package:open_file/open_file.dart';

class AlertDialogSample extends StatelessWidget {
  const AlertDialogSample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('データを消してしまってもいいですか？'),
      content: Text('こうかいしませんね？'),
      actions: <Widget>[
        GestureDetector(
          child: Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: Text('はい'),
          onTap: () {},
        )
      ],
    );
  }
}

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

  Future<int> _deleteFile(String filename) async {
    try {
      final path = await _localPath;
      final file = File("$path/$filename");
      await file.delete();
    } catch (e) {
      return 0;
    }

    return 1;
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

    final detector2 = ShakeDetector.autoStart(onPhoneShake: () {});

    final detector = ShakeDetector.autoStart(onPhoneShake: () async {
      print("shake");
      if (!this.mounted) return;
      // Do stuff on phone shake
      if (entities.isEmpty) return;

      for (var entity in entities) {
        print("Deleting $entity");
        await _deleteFile(Path.basename(entity.path));
      }

      await RefreshList();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPressed() {
    print("HEY");
  }

  Widget _itemBuilder(BuildContext context, int index) {
    String filename = "";
    FileSystemEntity entity;
    Widget viewitem;
    print("entities.length:" + (entities.length).toString());
    if (entities.length != 0) {
      entity = entities[entities.length - 1 - index];
      filename = Path.basename(entity.path);
      print("filname:" + filename);

      void _pushedShare() {
        OpenFile.open(entity.path,
            type: "text/plain", uti: "public.plain-text");
      }

      viewitem = Dismissible(
        onDismissed: (direction) {
          if (!entities.isEmpty) {
            // Remove the item from the data source.
            _deleteFile(filename);

            // Then show a snackbar.
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$filename was deleted.')));

            RefreshList();
          }
        },
        background: Container(
          color: Colors.red,
          child: Icon(Icons.delete),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 30),
        ),
        key: UniqueKey(),
        child: Container(
          height: 70,
          child: ListTile(
            onTap: () => OpenFile.open(entity.path),
            title: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(filename),
                    Container(
                      child: Row(
                        children: [
                          //   TextButton(
                          //     onPressed: () {},
                          //     child: const Icon(Icons.drive_file_rename_outline),
                          //   ),
                          //   // TextButton(
                          //   //   onPressed: () {},
                          //   //   child: const Icon(Icons.open_in_browser),
                          //   // ),
                          TextButton(
                            onPressed: _pushedShare,
                            child: const Icon(Icons.share),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      viewitem = Card(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: const Text("There are no records."),
              ),
            ],
          ),
        ),
      );
    }

    print("return Container");
    return viewitem;
  }

  Future RefreshList() async {
    entities = await _FilesListInDocument;
    print(entities.length);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              print('Loading New Data');
              await RefreshList();
            },
            child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: entities.isEmpty ? 1 : entities.length,
                reverse: false,
                itemBuilder: _itemBuilder),
          ),
        ),
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
