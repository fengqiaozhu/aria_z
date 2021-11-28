// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../states/app.dart';
import '../components/custom_snack_bar.dart';

class DownloadSourceFile2Base64 {
  String content2Base64;

  String name;

  String path;

  DownloadSourceFile2Base64(this.name, this.path, this.content2Base64);
}

class AddNewAria2Task extends StatelessWidget {
  late Aria2TaskType taskType;
  AddNewAria2Task({Key? key}) : super(key: key);

  readDownloadSourceFileToBase64(FilePickerResult fileResult) {
    return fileResult.names
        .asMap()
        .keys
        .map((idx) => DownloadSourceFile2Base64(
            fileResult.names[idx] ?? '',
            fileResult.paths[idx] ?? '',
            base64Encode(fileResult.files[idx].bytes!)))
        .toList();
  }

  Widget showAddWidgetByTaskType() {
    late Widget w;
    switch (taskType.taskType) {
      case TaskType.torrent:
        w = TextButton(
            onPressed: () async {
              FilePickerResult? result =
                  // await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['torrent','zip']);
                  await FilePicker.platform.pickFiles(
                      type: FileType.any, allowMultiple: true, withData: true);
              if (result != null) {
                List<DownloadSourceFile2Base64> tmp =
                    readDownloadSourceFileToBase64(result);
                print(tmp);
              } else {
                // User canceled the picker
              }
            },
            child: const Text("选择种子文件"));
        break;
      default:
        w = const Text('添加新任务');
        break;
    }
    return w;
  }

  _submitNewTask(BuildContext context) {
    showCustomSnackBar(context, 1, const Text('添加任务成功'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    taskType = ModalRoute.of(context)?.settings.arguments as Aria2TaskType;
    return Scaffold(
      appBar: AppBar(
        title: Text('添加${taskType.name}任务'),
        actions: [
          IconButton(
              icon: const Icon(Icons.done),
              tooltip: '提交',
              onPressed: () => _submitNewTask(context))
        ],
      ),
      body: Container(
        child: showAddWidgetByTaskType(),
      ),
    );
  }
}
