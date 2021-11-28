import 'package:aria2/models/aria2GlobalStat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../utils/tools.dart';
import '../states/aria2.dart';
import '../states/app.dart';
import '../views/edit_aria2_server_config.dart'
    show Aria2ConnectConfigArguments;

Widget customDrawer(context) {
  _deleteServerConfig(BuildContext context, Aria2ConnectConfig config) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除服务器配置'),
          content: const Text('确定删除当前服务器配置吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Provider.of<AppState>(context, listen: false)
                    .removeAria2ConnectConfig(config);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  return Selector<AppState,
      Tuple2<List<Aria2ConnectConfig>, Aria2ConnectConfig?>>(
    selector: (BuildContext context, AppState app) =>
        Tuple2(app.aria2ConnectConfigs, app.selectedAria2ConnectConfig),
    builder: (context, app, _) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Builder(builder: (context) {
              return Selector<Aria2States, Aria2GlobalStat>(
                  selector: (BuildContext context, Aria2States aria2State) =>
                      aria2State.globalStatus,
                  builder: (context, Aria2GlobalStat gStatus, _) {
                    return DrawerHeader(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("AriaZ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              Text(
                                  app.item2 != null
                                      ? "已连接到: ${app.item2?.host}:${app.item2?.port}"
                                      : '未连接到任何服务器...',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text(
                                  "全局下载速度: ${bitToUnit(gStatus.downloadSpeed ?? 0)}/s",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16))
                            ],
                          ),
                        ));
                  });
            }),
            ...(app.item1.asMap().keys.map((idx) {
              Aria2ConnectConfig acc = app.item1[idx];
              return ListTile(
                leading:
                    acc.toJson().toString() == app.item2?.toJson().toString()
                        ? const Icon(Icons.check)
                        : const Icon(Icons.link),
                title: Text(
                  '${acc.host}:${acc.port}',
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                trailing: PopupMenuButton(
                  child: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('编辑'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).popAndPushNamed(
                          "/update_aria2_server",
                          arguments: Aria2ConnectConfigArguments(acc, idx));
                      // Navigator.of(context).pushNamed('/editServer',arguments: acc);
                    } else if (value == 'delete') {
                      _deleteServerConfig(context, acc);
                    }
                  },
                ),
                selected:
                    acc.toJson().toString() == app.item2?.toJson().toString(),
                onTap: () {
                  Provider.of<AppState>(context, listen: false)
                      .useAria2ConnectConfig(acc);
                  Navigator.pop(context);
                },
              );
            }).toList()),
            Builder(builder: (context) {
              return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('添加新的服务器地址'),
                  onTap: () => Navigator.of(context)
                      .popAndPushNamed("/add_new_aria2_server"));
            }),
            Builder(builder: (context) {
              return ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () =>
                    Navigator.of(context).popAndPushNamed("/global_setting"),
              );
            })
          ],
        ),
      );
    },
  );
}
