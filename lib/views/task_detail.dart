import 'package:aria2/models/index.dart';
import 'package:aria_z/states/aria2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/tools.dart';
// import 'package:aria2/aria2.dart';
// import 'dart:async';

GlobalKey<_TabViewsBodyWidgtState> _tabViewBodyKey = GlobalKey();

const List<Tab> tabs = <Tab>[
  Tab(text: '任务信息'),
  Tab(text: '文件列表'),
  Tab(text: '连接节点'),
];

// ignore: must_be_immutable
class TaskDetail extends StatelessWidget {
  TaskDetail({Key? key}) : super(key: key);
  Aria2Task taskInfo = Aria2Task();

  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context)?.settings.arguments as List;
    String _gid = args[0];
    String _taskName = args[1];
    TaskType _taskType = args[2];
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
              title: Text(_taskName),
              bottom: const TabBar(tabs: tabs),
            ),
            body: TabViewsBodyWidgt(
              gid: _gid,
              taskName: _taskName,
              taskType: _taskType,
              key: _tabViewBodyKey,
            ));
      }),
    );
  }
}

class TabViewsBodyWidgt extends StatefulWidget {
  final String gid;

  final String taskName;

  final TaskType taskType;

  const TabViewsBodyWidgt({Key? key, required this.gid,required this.taskName,required this.taskType}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TabViewsBodyWidgtState();
}

class _TabViewsBodyWidgtState extends State<TabViewsBodyWidgt> {

  String get taskName=>widget.taskName;
  TaskType get taskType=>widget.taskType;
  
  @override
  Widget build(BuildContext context) {
    Aria2States _at = Provider.of<Aria2States>(context);
    Aria2Task taskInfo = [
      ..._at.downloadingTasks,
      ..._at.waittingTasks,
      ..._at.completedTasks
    ].where((t) => t.gid == widget.gid).first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
      child: TabBarView(
        children: [
          TaskInfo(info: taskInfo),
          FileList(info: taskInfo),
          Connections(info: taskInfo)
        ],
      ),
    );
  }
}

class TaskInfo extends StatefulWidget {
  final Aria2Task info;

  const TaskInfo(
      {Key? key,
      required this.info})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("任务名称："),
            Flexible(child: Text(_tabViewBodyKey.currentState?.taskName??''))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("已下载："),
            Flexible(
                child: Text(
                    "${formatFileSize(widget.info.completedLength ?? 0)}/${formatFileSize(widget.info.totalLength ?? 0)}"))
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
    return SingleChildScrollView(
      child: Text(info.files.toString()),
    );
  }
}
