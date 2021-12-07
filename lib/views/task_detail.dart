import 'dart:async';

import 'package:aria2/models/index.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:aria_z/states/app.dart';
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

  const TabViewsBodyWidgt(
      {Key? key,
      required this.gid,
      required this.taskName,
      required this.taskType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TabViewsBodyWidgtState();
}

class _TabViewsBodyWidgtState extends State<TabViewsBodyWidgt> {
  String get taskName => widget.taskName;
  TaskType get taskType => widget.taskType;

  @override
  Widget build(BuildContext context) {
    Aria2States _at = Provider.of<Aria2States>(context);
    Aria2Task taskInfo = [
      ..._at.downloadingTasks,
      ..._at.waittingTasks,
      ..._at.completedTasks
    ].where((t) => t.gid == widget.gid).first;
    return TabBarView(
      children: [
        TaskInfo(info: taskInfo),
        FileList(info: taskInfo),
        PeerListWidgt(gid: taskInfo.gid!),
      ],
    );
  }
}

class TaskInfo extends StatefulWidget {
  final Aria2Task info;

  const TaskInfo({Key? key, required this.info}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {
  Widget itemTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget itemText(String text) {
    return Expanded(
      child: Text(
        text,
        maxLines: 100,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _taskStatusWidgt(String stat) {
    String statLabel = stat;
    Color statColor = Theme.of(context).colorScheme.primary;
    switch (stat) {
      case 'active':
        statLabel = '下载中';
        break;
      case 'watting':
        statLabel = '队列中';
        statColor = Colors.grey;
        break;
      case 'complete':
        statLabel = '已完成';
        statColor = Colors.green;
        break;
      case 'error':
        statLabel = '下载错误';
        statColor = Colors.red;
        break;
      case 'paused':
        statLabel = '已暂停';
        statColor = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: statColor,
      ),
      child: Text(
        statLabel,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  List<int> get _bitField {
    String bf = widget.info.bitfield ?? '';
    int c = widget.info.numPieces ?? 0;
    String _bf2 = '';
    for (var i = 0; i < bf.length; i++) {
      String _b2 = '0000' + int.parse(bf[i], radix: 16).toRadixString(2);
      _bf2 += _b2.substring(_b2.length - 4);
    }
    _bf2 = _bf2.substring(0, c);
    return _bf2.split('').map((e) => int.parse(e)).toList();
  }

  Widget _bitFieldWidgt() {
    List<Widget> blocks = _bitField
        .map((e) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).backgroundColor),
                color: e == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).cardColor,
              ),
              width: 12,
              height: 12,
            ))
        .toList();

    return Wrap(
      direction: Axis.horizontal,
      children: blocks,
      spacing: 3,
      runSpacing: 3,
    );
  }

// const EdgeInsets.fromLTRB(10, 15, 10, 20),
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            itemTitle("任务名称："),
            itemText(_tabViewBodyKey.currentState?.taskName ?? '')
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            itemTitle("已下载："),
            itemText(
                "${formatFileSize(widget.info.completedLength ?? 0)}/${formatFileSize(widget.info.totalLength ?? 0)}")
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            itemTitle("任务状态："),
            _taskStatusWidgt(widget.info.status ?? '')
          ],
        ),
        const SizedBox(height: 8),
        Column(children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              itemTitle("区块信息："),
              itemText(
                  '共${widget.info.numPieces ?? 0}个区块，${widget.info.pieceLength ?? 0}字节'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            child: _bitFieldWidgt(),
          )
        ])
      ]),
    ));
  }
}

class PeerListWidgt extends StatefulWidget {
  const PeerListWidgt({Key? key, required this.gid}) : super(key: key);
  final String gid;
  @override
  State<StatefulWidget> createState() => _PeerListWidgtState();
}

class _PeerListWidgtState extends State<PeerListWidgt> {
  List<Aria2Peer> _peers = [];
  late Timer _periodicTimer;

  getPeers(AppState _app) async {
    handleAria2ApiResponse<List<Aria2Peer>>(
        context, await _app.aria2!.getAria2Peers(widget.gid), (peers) {
      setState(() {
        _peers = peers;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    AppState _app = Provider.of<AppState>(context, listen: false);
    int _time = _app.intervalSecond;
    getPeers(_app);
    _periodicTimer = Timer.periodic(Duration(seconds: _time), (t) async {
      await getPeers(_app);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _periodicTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_peers.map((e) => e.toJson()).toString());
  }
}

class FileList extends StatefulWidget {
  const FileList({Key? key, required this.info}) : super(key: key);
  final Aria2Task info;

  @override
  State<StatefulWidget> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  Widget _fileTreeView(List<Aria2File> files) {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
        shrinkWrap: false,
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          Aria2File file = files[index];
          String fileName = file.path!.split('/').last;
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: Container(
              color: Theme.of(context).cardColor,
              child: ListTile(
                title: Text(fileName, style: const TextStyle(fontSize: 15)),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${formatFileSize(file.completedLength)} / ${formatFileSize(file.length)}',
                        style: const TextStyle(fontFamily: 'Coda'),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        minHeight: 4,
                        value: (file.completedLength ?? 0) / (file.length ?? 1),
                      )
                    ]),
                trailing: Icon(Icons.check_circle_rounded,
                    color: file.completedLength == file.length
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).secondaryHeaderColor),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // String dPath = widget.info.dir ?? "";
    List<Aria2File> files =
        (widget.info.files ?? []).map((f) => Aria2File.fromJson(f)).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: _fileTreeView(files),
    );
  }
}
