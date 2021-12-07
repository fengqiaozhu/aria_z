import 'dart:convert';

import 'package:aria2/aria2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../states/app.dart';
import '../states/aria2.dart' show Aria2States, NewTaskOption, TaskType;
import '../components/custom_snack_bar.dart';
import '../utils/tools.dart';

GlobalKey<_NewTaskCreaterState> newTaskCreaterKey = GlobalKey();
GlobalKey<_NewTaskConfigState> newTaskConfigKey = GlobalKey();
GlobalKey<_SubmitActionWidgtState> submitActionKey = GlobalKey();

final GlobalKey optionFormKey = GlobalKey<FormState>();

class _DownloadSourceFile2Base64 {
  String content2Base64;

  String name;

  String path;

  _DownloadSourceFile2Base64(this.name, this.path, this.content2Base64);
}

class _TaskConfig {
  String downloadPath;

  BitUnit speedLimit;

  bool allowOverwrite;

  _TaskConfig(
      {required this.downloadPath,
      required this.speedLimit,
      required this.allowOverwrite});
}

class AddNewAria2Task extends StatelessWidget {
  static const List<Tab> tabs = <Tab>[
    Tab(text: '添加'),
    Tab(text: '选项'),
  ];
  const AddNewAria2Task({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Aria2TaskType taskType =
        ModalRoute.of(context)?.settings.arguments as Aria2TaskType;
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
                NewTaskConfig(key: newTaskConfigKey)
              ]),
            );
          },
        ));
  }
}

class SubmitActionWidgt extends StatefulWidget {
  final Aria2TaskType taskType;

  const SubmitActionWidgt({Key? key, required this.taskType}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubmitActionWidgtState();
}

class _SubmitActionWidgtState extends State<SubmitActionWidgt> {
  /// 提交新增的任务
  _submitNewTask(BuildContext context) async {
    List<String>? source = newTaskCreaterKey.currentState?.getNewTaskSource();
    if (source != null && source.isNotEmpty) {
      if (optionFormKey.currentState == null ||
          (optionFormKey.currentState as FormState).validate()) {
        final Aria2Option option =
            newTaskConfigKey.currentState?.getTaskOption() ?? Aria2Option();
        handleAria2ApiResponse(
            context,
            await Provider.of<AppState>(context, listen: false)
                .aria2!
                .addNewTask(
                    NewTaskOption(widget.taskType.taskType, source, option)),
            (data) {
          showCustomSnackBar(context, 1, const Text('添加任务成功'));
          Navigator.pop(context);
        });
      } else {
        showCustomSnackBar(context, 2, const Text('请检查任务选项输入！'));
      }
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
  final Aria2TaskType taskType;

  const NewTaskCreater({Key? key, required this.taskType}) : super(key: key);

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
                setState(() {
                  widget.taskType.taskType == TaskType.magnet
                      ? magnetLinks.add(inputUrl)
                      : downloadUrls.add(inputUrl);
                });
                Navigator.of(context).pop();
                submitActionKey.currentState?._submitNewTask(context);
              },
            ),
            TextButton(
              child: const Text('添加'),
              onPressed: () {
                setState(() {
                  widget.taskType.taskType == TaskType.magnet
                      ? magnetLinks.add(inputUrl)
                      : downloadUrls.add(inputUrl);
                });
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
                    onPressed: () => {
                      setState(() {
                        widget.taskType.taskType == TaskType.magnet
                            ? magnetLinks.removeAt(idx)
                            : downloadUrls.removeAt(idx);
                      })
                    },
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
    super.build(context);
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
  late Aria2States aria2States;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    aria2States = Provider.of<Aria2States>(context, listen: false);
    taskConfig = _TaskConfig(
        downloadPath: aria2States.globalOption?.dir ?? '',
        speedLimit: bitToUnit(aria2States.globalOption?.maxDownloadLimit ?? 0),
        allowOverwrite: aria2States.globalOption?.allowOverwrite ?? true);
  }

  Aria2Option getTaskOption() {
    return Aria2Option.fromJson({
      'dir': taskConfig.downloadPath == aria2States.globalOption?.dir
          ? null
          : taskConfig.downloadPath,
      'max-download-limit': taskConfig.speedLimit.bit == '0'
          ? null
          : (taskConfig.speedLimit.bit + taskConfig.speedLimit.unit),
      'allow-overwrite':
          taskConfig.allowOverwrite == aria2States.globalOption?.allowOverwrite
              ? null
              : taskConfig.allowOverwrite,
    });
  }

  /// 验证下载路径是否合法
  dirValidator(String dir) {
    if (dir.isEmpty) {
      return '请输入下载目录';
    }
    if (dir.startsWith(aria2States.globalOption!.dir!)) {
      return null;
    }
    return '文件必须在保存在全局下载目录"${aria2States.globalOption!.dir!}"下';
  }

  /// 验证下载速度是否合法
  speedLimitInputValidator(String number) {
    if (number.isEmpty) {
      return '请输入速度限制';
    }
    if (number.length > 1 && number.startsWith('0')) {
      return '速度限制不能以0开头';
    }
    return double.tryParse(number) == null ? '请输入合法数字' : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
        key: optionFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 16),
                aria2States.globalOption != null &&
                        aria2States.globalOption!.dir != null
                    ? TextFormField(
                        controller: TextEditingController(
                            text: taskConfig.downloadPath),
                        onChanged: (v) => taskConfig.downloadPath = v,
                        validator: (v) => dirValidator(v ?? ''),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '下载路径',
                            contentPadding: EdgeInsets.all(8)),
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                TextFormField(
                  controller:
                      TextEditingController(text: taskConfig.speedLimit.bit),
                  onChanged: (v) => taskConfig.speedLimit.bit = v,
                  validator: (v) => speedLimitInputValidator(v ?? ''),
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '限速',
                      contentPadding: const EdgeInsets.all(8),
                      suffix: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        value: taskConfig.speedLimit.unit == ''
                            ? 'K'
                            : taskConfig.speedLimit.unit,
                        onChanged: (String? newVal) {
                          setState(() {
                            taskConfig.speedLimit.unit = newVal!;
                          });
                        },
                        items: <String>["K", "M"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value + 'B/s'),
                          );
                        }).toList(),
                      ))),
                ),
                SwitchListTile(
                    title: const Text("允许覆盖历史下载同名文件"),
                    value: taskConfig.allowOverwrite,
                    onChanged: (newVal) {
                      setState(() {
                        taskConfig.allowOverwrite = newVal;
                      });
                    })
              ],
            )));
  }
}
