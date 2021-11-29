// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../states/app.dart';
import '../states/aria2.dart' show TaskType, NewTaskOption;
import '../components/custom_snack_bar.dart';

GlobalKey<_NewTaskCreaterState> newTaskCreaterKey = GlobalKey();

class _DownloadSourceFile2Base64 {
  String content2Base64;

  String name;

  String path;

  _DownloadSourceFile2Base64(this.name, this.path, this.content2Base64);
}

class _TaskSpeed {
  double speedNumber;

  String speedUnit;

  _TaskSpeed(this.speedNumber, this.speedUnit);
}

class _TaskConfig {
  String downloadPath;

  _TaskSpeed speedLimit;

  _TaskConfig(this.downloadPath, this.speedLimit);
}

class AddNewAria2Task extends StatefulWidget {
  const AddNewAria2Task({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AddNewAria2TaskState();
}

class _AddNewAria2TaskState extends State<AddNewAria2Task> {
  static const List<Tab> tabs = <Tab>[
    Tab(text: '添加'),
    Tab(text: '选项'),
  ];

  late Aria2TaskType taskType;

  _submitNewTask(BuildContext context) async {
    List<String>? source = newTaskCreaterKey.currentState?.getNewTaskSource();
    if (source != null && source.isNotEmpty) {
      await Provider.of<AppState>(context, listen: false)
          .aria2
          ?.addNewTask(NewTaskOption(taskType.taskType, source));
      showCustomSnackBar(context, 1, const Text('添加任务成功'));
      Navigator.pop(context);
    } else {
      showCustomSnackBar(context, 2, const Text('请检查下载源是否添加正确！'));
    }
  }

  @override
  Widget build(BuildContext context) {
    taskType = ModalRoute.of(context)?.settings.arguments as Aria2TaskType;
    return DefaultTabController(
        length: tabs.length,
        child: Builder(
          builder: (BuildContext context) {
            final TabController tabController =
                DefaultTabController.of(context)!;
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                // Your code goes here.
                // To get index of current tab use tabController.index
              }
            });
            return Scaffold(
              appBar: AppBar(
                title: Text('添加${taskType.name}任务'),
                bottom: const TabBar(tabs: tabs),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.done),
                      tooltip: '提交',
                      onPressed: () => _submitNewTask(context))
                ],
              ),
              body: TabBarView(children: [
                NewTaskCreater(key: newTaskCreaterKey, taskType: taskType),
                const NewTaskConfig()
              ]),
            );
          },
        ));
  }
}

class NewTaskCreater extends StatefulWidget {
  Aria2TaskType taskType;

  NewTaskCreater({Key? key, required this.taskType}) : super(key: key);

  @override
  _NewTaskCreaterState createState() => _NewTaskCreaterState();
}

class _NewTaskCreaterState extends State<NewTaskCreater> {
  late List<_DownloadSourceFile2Base64> torrentFiles;
  late List<_DownloadSourceFile2Base64> metalinkFiles;
  late List<String> downloadUrl;
  late List<String> magnetLink;

  void readDownloadSourceFileToBase64({bool addMore = false}) async {
    FilePickerResult? result =
        // await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['torrent','zip']);
        await FilePicker.platform
            .pickFiles(type: FileType.any, allowMultiple: true, withData: true);
    if (result != null) {
      List<_DownloadSourceFile2Base64> files =
          widget.taskType.taskType == TaskType.metaLink
              ? metalinkFiles
              : torrentFiles;
      List<_DownloadSourceFile2Base64> b64 = result.names
          .asMap()
          .keys
          .map((idx) => _DownloadSourceFile2Base64(result.names[idx] ?? '',
              result.paths[idx] ?? '', base64Encode(result.files[idx].bytes!)))
          .toList();
      setState(() {
        if (widget.taskType.taskType == TaskType.metaLink) {
          addMore ? metalinkFiles.addAll(b64) : (metalinkFiles = b64);
        } else {
          addMore ? torrentFiles.addAll(b64) : (torrentFiles = b64);
        }
      });
    }
  }

  List<String>? getNewTaskSource() {
    switch (widget.taskType.taskType) {
      case TaskType.torrent:
        return torrentFiles.map((tf) => tf.content2Base64).toList();
      case TaskType.metaLink:
        return metalinkFiles.map((tf) => tf.content2Base64).toList();
      case TaskType.url:
        return downloadUrl;
      case TaskType.magnet:
        return magnetLink;
    }
  }

  Widget showAddWidgetByTaskType() {
    late Widget w;
    switch (widget.taskType.taskType) {
      case TaskType.torrent:
      case TaskType.metaLink:
        List<_DownloadSourceFile2Base64> files =
            widget.taskType.taskType == TaskType.torrent
                ? torrentFiles
                : metalinkFiles;
        String btnText = widget.taskType.taskType == TaskType.torrent
            ? 'Torrent'
            : 'MetaLink';
        String fileChooseTip = widget.taskType.taskType == TaskType.torrent
            ? '支持种子文件格式 ".torrent" '
            : '支持Metalink文件格式 ".metalink, .meta4"';
        w = Column(
            mainAxisAlignment: torrentFiles.isEmpty
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              ElevatedButton(
                child: Text('${files.isNotEmpty ? "重新" : ""}选择$btnText文件'),
                onPressed: readDownloadSourceFileToBase64,
              ),
              files.isEmpty ? Text(fileChooseTip) : const SizedBox(height: 0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, idx) => ListTile(
                  title: Text(
                    files[idx].name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: false,
                  ),
                  trailing: IconButton(
                    color: Colors.red,
                    icon: const Icon(Icons.close),
                    onPressed: () => files.removeAt(idx),
                  ),
                ),
              ),
              files.isNotEmpty
                  ? TextButton.icon(
                      onPressed: () =>
                          readDownloadSourceFileToBase64(addMore: true),
                      icon: const Icon(Icons.add),
                      label: const Text('添加更多'))
                  : const SizedBox(height: 0),
            ]);
        break;
      case TaskType.magnet:
      case TaskType.url:
        break;
    }
    return w;
  }

  @override
  void initState() {
    super.initState();
    torrentFiles = [];
    metalinkFiles = [];
    downloadUrl = [];
    magnetLink = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8), child: showAddWidgetByTaskType());
  }
}

class NewTaskConfig extends StatefulWidget {
  const NewTaskConfig({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskConfigState();
}

class _NewTaskConfigState extends State<NewTaskConfig> {
  late _TaskConfig taskConfig;
  @override
  void initState() {
    super.initState();
    taskConfig = _TaskConfig('/download', _TaskSpeed(0, 'K'));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '下载路径',
                  contentPadding: EdgeInsets.all(8)),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: '限速',
                  contentPadding: const EdgeInsets.all(8),
                  suffix: DropdownButton(
                    value: taskConfig.speedLimit.speedUnit,
                    onChanged: (String? newVal) {
                      setState(() {
                        taskConfig.speedLimit.speedUnit = newVal!;
                      });
                    },
                    items: <String>["K", "M"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value + 'B/s'),
                      );
                    }).toList(),
                  )),
            )
          ],
        ));
  }
}
