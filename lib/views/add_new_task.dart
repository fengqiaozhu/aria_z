// ignore_for_file: must_be_immutable, must_call_super

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../states/app.dart';
import '../states/aria2.dart' show TaskType, NewTaskOption;
import '../components/custom_snack_bar.dart';

GlobalKey<_NewTaskCreaterState> newTaskCreaterKey = GlobalKey();
GlobalKey<_SubmitActionWidgtState> submitActionKey = GlobalKey();

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

class AddNewAria2Task extends StatelessWidget {
  static const List<Tab> tabs = <Tab>[
    Tab(text: '添加'),
    Tab(text: '选项'),
  ];

  late Aria2TaskType taskType;

  AddNewAria2Task({Key? key}) : super(key: key);

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
                  SubmitActionWidgt(key: submitActionKey, taskType: taskType)
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

class SubmitActionWidgt extends StatefulWidget {
  Aria2TaskType taskType;

  SubmitActionWidgt({Key? key, required this.taskType}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubmitActionWidgtState();
}

class _SubmitActionWidgtState extends State<SubmitActionWidgt> {
  _submitNewTask(BuildContext context) async {
    List<String>? source = newTaskCreaterKey.currentState?.getNewTaskSource();
    if (source != null && source.isNotEmpty) {
      await Provider.of<AppState>(context, listen: false)
          .aria2
          ?.addNewTask(NewTaskOption(widget.taskType.taskType, source));
      showCustomSnackBar(context, 1, const Text('添加任务成功'));
      Navigator.pop(context);
    } else {
      showCustomSnackBar(context, 2, const Text('请检查下载源是否添加正确！'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.done),
        tooltip: '提交',
        onPressed: () => _submitNewTask(context));
  }
}

/// 新任务源编辑器
class NewTaskCreater extends StatefulWidget {
  Aria2TaskType taskType;

  NewTaskCreater({Key? key, required this.taskType}) : super(key: key);

  @override
  _NewTaskCreaterState createState() => _NewTaskCreaterState();
}

class _NewTaskCreaterState extends State<NewTaskCreater>
    with AutomaticKeepAliveClientMixin<NewTaskCreater> {
  late List<_DownloadSourceFile2Base64> torrentFiles;
  late List<_DownloadSourceFile2Base64> metalinkFiles;
  late List<String> downloadUrls;
  late List<String> magnetLinks;

  ///读取种子文件或metalink文件
  void readDownloadSourceFileToBase64({bool addMore = false}) async {
    FilePickerResult? result =
        // await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['torrent','zip']);
        await FilePicker.platform
            .pickFiles(type: FileType.any, allowMultiple: true, withData: true);
    if (result != null) {
      /// 需要校验选择的文件，文件扩展名校验
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

  /// 链接地址校验
  String? linkValidator() {}

  /// 弹出链接输入dialog模态框
  void _showInputLink() {
    String inputUrl = '';
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('输入链接地址'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: TextEditingController(text: inputUrl),
                  maxLines: 4,
                  onChanged: (v) => inputUrl = v,
                  validator: (v) => linkValidator(),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '链接地址',
                      contentPadding: EdgeInsets.all(8)),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('添加并开始下载'),
              onPressed: () {
                widget.taskType.taskType == TaskType.magnet
                    ? magnetLinks.add(inputUrl)
                    : downloadUrls.add(inputUrl);
                Navigator.of(context).pop();
                submitActionKey.currentState?._submitNewTask(context);
              },
            ),
            TextButton(
              child: const Text('添加'),
              onPressed: () {
                widget.taskType.taskType == TaskType.magnet
                    ? magnetLinks.add(inputUrl)
                    : downloadUrls.add(inputUrl);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 返回下载源数据
  List<String>? getNewTaskSource() {
    switch (widget.taskType.taskType) {
      case TaskType.torrent:
        return torrentFiles.map((tf) => tf.content2Base64).toList();
      case TaskType.metaLink:
        return metalinkFiles.map((tf) => tf.content2Base64).toList();
      case TaskType.url:
        return downloadUrls;
      case TaskType.magnet:
        return magnetLinks;
    }
  }

  ///根据新任务的类型显示不同的添加控件
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
            mainAxisAlignment: files.isEmpty
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
        List<String> links = widget.taskType.taskType == TaskType.magnet
            ? magnetLinks
            : downloadUrls;
        String btnText =
            widget.taskType.taskType == TaskType.url ? 'URL' : '磁力链';
        String fileChooseTip = widget.taskType.taskType == TaskType.url
            ? '支持协议类型包括 HTTP/FTP/SFTP/BitTorrent'
            : '支持"magnet:?"磁力链';
        w = Column(
            mainAxisAlignment: links.isEmpty
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                child: Text('添加$btnText地址'),
                onPressed: _showInputLink,
              ),
              links.isEmpty ? Text(fileChooseTip) : const SizedBox(height: 0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: links.length,
                itemBuilder: (context, idx) => ListTile(
                  title: Text(
                    links[idx],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: false,
                  ),
                  trailing: IconButton(
                    color: Colors.red,
                    icon: const Icon(Icons.close),
                    onPressed: () => links.removeAt(idx),
                  ),
                ),
              ),
            ]);
        break;
    }
    return w;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    torrentFiles = [];
    metalinkFiles = [];
    downloadUrls = [];
    magnetLinks = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8), child: showAddWidgetByTaskType());
  }
}

/// 新任务配置编辑器
class NewTaskConfig extends StatefulWidget {
  const NewTaskConfig({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskConfigState();
}

class _NewTaskConfigState extends State<NewTaskConfig>
    with AutomaticKeepAliveClientMixin<NewTaskConfig> {
  late _TaskConfig taskConfig;

  @override
  bool get wantKeepAlive => true;

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
