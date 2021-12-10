import 'package:aria2/models/aria2Task.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:aria_z/components/speed_shower.dart';
import 'package:aria_z/l10n/localization_intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../states/app.dart' show AppState;
import '../states/aria2.dart' show Aria2States, TaskType;
import '../utils/tools.dart';

List<Widget> taskListTileWidget(BuildContext context, AppState app,
    Aria2States aria2States, List<Aria2Task> taskList) {
  AriazLocalizations _l10n = AriazLocalizations.of(context);
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
        w = Text(_l10n.waiting);
        break;
      case 'pausing':
        w = Text(_l10n.pausing);
        break;
      case 'unparsing':
        w = Text(_l10n.unparsing);
        break;
      case 'complete':
        w = Text(_l10n.complete);
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
                      onPressed: (BuildContext context) async {
                        handleAria2ApiResponse<String>(
                            context,
                            await app.aria2!
                                .removeTask(task.gid!, task.status!), (res) {
                          if (res == 'OK') {
                            aria2States
                                .removeCompletedTaskFromLocalList(task.gid!);
                          }
                          // showCustomSnackBar(context, 1, Text(res));
                        });
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: _l10n.deleteText,
                    ),
                  ],
                ),
                child: ListTile(
                    onTap: () async {
                      var gid = task.gid!;
                      Navigator.of(context).pushNamed('/task_detail',
                          arguments: [gid, _taskName, _taskType]);
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
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: task.status == 'paused'
                              ? Text(_l10n.paused)
                              : DefaultTextStyle(
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                      fontFamily: 'Coda'),
                                  child: SpeedShower(
                                      downloadSpeed: task.downloadSpeed,
                                      uploadSpeed: _taskType != TaskType.torrent
                                          ? null
                                          : task.uploadSpeed)),
                        ))
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
