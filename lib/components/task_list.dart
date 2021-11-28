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
          icon: const Icon(Icons.pause),
          onPressed: aria2States.opratingGids.contains(gid)
              ? null
              : () async {
                  print('Pausing $gid');
                  if (gid != "") {
                    await app.aria2?.pauseTask(gid);
                  }
                },
        );
        break;
      case 'paused':
        w = IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: aria2States.opratingGids.contains(gid)
              ? null
              : () async {
                print('Unpausing $gid');
                  if (gid != "") {
                    await app.aria2?.unPauseTask(gid);
                  }
                },
        );
        break;
      case 'waiting':
      case 'complete':
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
                title: Text(task.bittorrent?["info"]["name"]),
                trailing: trailingOption(task.gid ?? '', task.status ?? '')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(children: <Widget>[
                  const Icon(Icons.upload),
                  Text(bitToUnit(task.uploadSpeed ?? 0) + '/S')
                ]),
                const SizedBox(width: 8),
                Row(children: <Widget>[
                  const Icon(Icons.download),
                  Text(bitToUnit(task.downloadSpeed ?? 0) + '/S')
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
