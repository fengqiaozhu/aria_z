import 'package:aria2/models/aria2Task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../states/app.dart' show AppState;
import '../states/aria2.dart' show Aria2States, TaskType;
import '../utils/tools.dart';

List<Widget> taskListTileWidget(BuildContext context, AppState app,
    Aria2States aria2States, List<Aria2Task> taskList) {
  Widget trailingOption(String gid, String status) {
    late Widget w = Text(status);
    switch (status) {
      case 'active':
        w = IconButton(
            color: Colors.redAccent,
            icon: const Icon(Icons.pause),
            onPressed: () async {
              if (gid != "") {
                await app.aria2?.pauseTask(gid);
              }
            });
        break;
      case 'paused':
        w = IconButton(
          color: Colors.lightGreen,
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            if (gid != "") {
              await app.aria2?.unPauseTask(gid);
            }
          },
        );
        break;
      case 'waiting':
        w = const Text("队列中");
        break;
      case 'pausing':
        w = const Text("正在暂停");
        break;
      case 'unparsing':
        w = const Text("正在启动");
        break;
      case 'complete':
        w = const Text("已完成");
        break;
    }
    return w;
  }

  return taskList
      // .where((element) => element.bittorrent?["info"] != null)
      .map((task) {
    late TaskType _taskType;
    late String _taskName;

    if (task.bittorrent == null) {
      String uri = task.files?[0]['uris'][0]['uri'] as String;
      _taskType = TaskType.url;
      _taskName = uri.split('/').last;
    } else if (task.bittorrent != null) {
      if (task.bittorrent!.containsKey('info')) {
        _taskType = TaskType.torrent;
        _taskName = task.bittorrent?["info"]["name"] ?? '';
      } else {
        _taskType = TaskType.magnet;
        _taskName = '[METADATA]${task.infoHash}';
      }
    } else {
      _taskType = TaskType.metaLink;
      _taskName = '==========metaLink============';
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Slidable(
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) =>
                          app.aria2?.removeTask(task.gid!),
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                    onTap: () async {
                      var gid = task.gid ?? '';
                      if (gid != "") {
                        Aria2Task? ts = await app.aria2?.tellStatus(gid);
                        Navigator.of(context).pushNamed('/task_detail',
                            arguments: [ts, _taskName, _taskType]);
                      }
                    },
                    leading: Icon(app.aria2TaskTypes
                        .where((att) => att.taskType == _taskType)
                        .first
                        .icon),
                    title: Text(
                      _taskName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      // softWrap: false,
                    ),
                    trailing:
                        trailingOption(task.gid ?? '', task.status ?? ''))),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      "${formatFileSize(task.completedLength ?? 0)} / ${formatFileSize(task.totalLength ?? 0)}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontFamily: 'Coda'),
                    )),
                    Expanded(
                        flex: 1,
                        child: DefaultTextStyle(
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontFamily: 'Coda'),
                            child: Text.rich(TextSpan(
                              children: [
                                task.status == 'paused'
                                    ? const WidgetSpan(child: Text('已暂停'))
                                    : TextSpan(children: [
                                        const WidgetSpan(
                                            child: Icon(
                                          Icons.file_download_outlined,
                                          size: 18,
                                          color: Colors.green,
                                        )),
                                        TextSpan(
                                            text: formatSpeed(
                                                task.downloadSpeed ?? 0)),
                                      ]),
                                _taskType != TaskType.torrent
                                    ? const WidgetSpan(child: SizedBox())
                                    : const WidgetSpan(
                                        child: SizedBox(
                                        height: 16,
                                        child: VerticalDivider(
                                          color: Colors.grey,
                                          thickness: 2,
                                          width: 20,
                                        ),
                                      )),
                                // const TextSpan(
                                //     text: '     ',
                                //     style: TextStyle(
                                //         fontWeight:
                                //             FontWeight.w800)),
                                _taskType != TaskType.torrent
                                    ? const WidgetSpan(child: SizedBox())
                                    : TextSpan(children: [
                                        const WidgetSpan(
                                            child: Icon(
                                          Icons.file_upload_outlined,
                                          size: 18,
                                          color: Colors.red,
                                        )),
                                        TextSpan(
                                            text: formatSpeed(
                                                task.uploadSpeed ?? 0)),
                                      ])
                              ],
                            ))))
                  ],
                )),
            LinearProgressIndicator(
                value: (task.completedLength ?? 0) /
                    (task.totalLength == 0 ? 1 : task.totalLength ?? 1)),
          ],
        ),
      ),
    );
  }).toList();
}
