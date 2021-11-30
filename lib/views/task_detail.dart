import 'package:aria2/models/index.dart';
import 'package:flutter/material.dart';
import '../utils/tools.dart';
// import 'package:aria2/aria2.dart';
// import 'dart:async';

const List<Tab> tabs = <Tab>[
  Tab(text: '任务信息'),
  Tab(text: '连接节点'),
  Tab(text: '文件列表'),
];

class TaskDetail extends StatelessWidget {
  TaskDetail({Key? key}) : super(key: key);
  Aria2Task taskInfo = Aria2Task();

  @override
  Widget build(BuildContext context) {
    taskInfo = ModalRoute.of(context)?.settings.arguments as Aria2Task;
    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
        return Scaffold(
            appBar: AppBar(
              title: Text(taskInfo.bittorrent?["info"]["name"]),
              bottom: const TabBar(tabs: tabs),
            ),
            body: TabBarView(
              children: [
                TaskInfo(info: taskInfo),
                Connections(info: taskInfo),
                FileList(info: taskInfo)
              ],
            ));
      }),
    );
  }
}

class TaskInfo extends StatelessWidget {
  const TaskInfo({Key? key, required this.info}) : super(key: key);
  final Aria2Task info;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("任务名称："),
            Flexible(child: Text(info.bittorrent?['info']['name']))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("已下载："),
            Flexible(
                child: Text(
                    "${formatFileSize(info.completedLength ?? 0)}/${formatFileSize(info.totalLength ?? 0)}"))
          ],
        )
      ]),
    );
  }
}

class Connections extends StatelessWidget {
  const Connections({Key? key, required this.info}) : super(key: key);
  final Aria2Task info;
  @override
  Widget build(BuildContext context) {
    return const Text("连接节点");
  }
}

class FileList extends StatelessWidget {
  const FileList({Key? key, required this.info}) : super(key: key);
  final Aria2Task info;
  @override
  Widget build(BuildContext context) {
    return const Text("文件列表");
  }
}
