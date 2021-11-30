import 'package:aria2/models/aria2Task.dart';
import 'package:flutter/material.dart';
import '../states/app.dart' show AppState;
import '../states/aria2.dart' show Aria2States;
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
      .where((element) => element.bittorrent?["info"] != null)
      .map((task) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                onTap: () async {
                  var gid = task.gid ?? '';
                  if (gid != "") {
                    Aria2Task? ts = await app.aria2?.tellStatus(gid);
                    Navigator.of(context)
                        .pushNamed('/task_detail', arguments: ts);
                  }
                },
                title: Text(
                  task.bittorrent?["info"]["name"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  // softWrap: false,
                ),
                trailing: trailingOption(task.gid ?? '', task.status ?? '')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(children: <Widget>[
                  const Icon(Icons.upload),
                  Text(formatSpeed(task.uploadSpeed ?? 0))
                ]),
                const SizedBox(width: 8),
                Row(children: <Widget>[
                  const Icon(Icons.download),
                  Text(formatSpeed(task.downloadSpeed ?? 0))
                ])
              ],
            ),
            LinearProgressIndicator(
                value: (task.completedLength ?? 0) /
                    (task.totalLength == 0 ? 1 : task.totalLength ?? 1)),
          ],
        ),
      ),
    );
  }).toList();
}
