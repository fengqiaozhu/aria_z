// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../states/app.dart';
import '../components/custom_snack_bar.dart';

class AddNewAria2Task extends StatelessWidget {
  late Aria2TaskType taskType;
  AddNewAria2Task({Key? key}) : super(key: key);

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
        child: const Text('添加新任务'),
      ),
    );
  }
}
