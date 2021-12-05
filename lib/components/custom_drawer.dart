import 'package:aria2/aria2.dart';
import 'package:aria2/models/aria2GlobalStat.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../utils/tools.dart';
import '../states/aria2.dart';
import '../states/app.dart';
import '../views/edit_aria2_server_config.dart'
    show Aria2ConnectConfigArguments;

Widget customDrawer(BuildContext _parentContext) {
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
          child: Column(
        children: [
          Builder(builder: (context) {
            return Selector<Aria2States,
                    Tuple2<Aria2GlobalStat?, Aria2Version?>>(
                selector: (BuildContext context, Aria2States aria2State) =>
                    Tuple2(aria2State.globalStatus, aria2State.versionInfo),
                builder: (context, serverInfo, _) {
                  return DrawerHeader(
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor),
                      child: DefaultTextStyle(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12),
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AriaZ",
                                    style: TextStyle(
                                        fontFamily: 'Coda', fontSize: 32)),
                                const SizedBox(height: 4),
                                Text(
                                    app.item2 != null
                                        ? "已连接到: ${app.item2?.host}:${app.item2?.port}"
                                        : '未连接到任何服务器...',
                                    style: const TextStyle()),
                                serverInfo.item2 != null
                                    ? Text(
                                        "aria2版本: ${serverInfo.item2?.version ?? ''}",
                                        style: const TextStyle())
                                    : const SizedBox(),
                                Chip(
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    avatar: const Icon(Icons.speed),
                                    label: DefaultTextStyle(
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontSize: 12),
                                        child: Text.rich(TextSpan(
                                          children: [
                                            TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                      child: Icon(
                                                    Icons
                                                        .file_download_outlined,
                                                    size: 18,
                                                    color: Colors.green,
                                                  )),
                                                  TextSpan(
                                                      text: formatSpeed(serverInfo
                                                              .item1
                                                              ?.downloadSpeed ??
                                                          0)),
                                                ],
                                                style: const TextStyle(
                                                  fontFamily: 'Coda',
                                                  fontSize: 14,
                                                )),
                                            const WidgetSpan(
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
                                            TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                      child: Icon(
                                                    Icons.file_upload_outlined,
                                                    size: 18,
                                                    color: Colors.red,
                                                  )),
                                                  TextSpan(
                                                      text: formatSpeed(serverInfo
                                                              .item1
                                                              ?.uploadSpeed ??
                                                          0)),
                                                ],
                                                style: const TextStyle(
                                                  fontFamily: 'Coda',
                                                  fontSize: 14,
                                                ))
                                          ],
                                        ))))
                              ],
                            ),
                          )));
                });
          }),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            // 使用 scrollbar 在滚动时显示滚动条
            child: Scrollbar(
                child: ListView.builder(
                    // listview 和父组件 scrollBar 都有 scrollController，此处需要指定 listview 独立的scrollController，否则在滑动时会触发多个scrollController同时触发的错误
                    controller: ScrollController(),
                    // listView 高度在列表中内容减少时自动收缩，默认为false，也就是列表高度在渲染完毕之后不会因为内容的减少而收缩
                    shrinkWrap: true,
                    itemCount: app.item1.length,
                    itemBuilder: (context, idx) {
                      Aria2ConnectConfig acc = app.item1[idx];
                      return ListTile(
                        minLeadingWidth: 10,
                        leading: acc.toJson().toString() ==
                                app.item2?.toJson().toString()
                            ? const Icon(Icons.check)
                            : const Icon(Icons.link),
                        title: Text(
                          acc.configName,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${acc.host}:${acc.port}',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(fontSize: 12),
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
                                  arguments:
                                      Aria2ConnectConfigArguments(acc, idx));
                              // Navigator.of(context).pushNamed('/editServer',arguments: acc);
                            } else if (value == 'delete') {
                              _deleteServerConfig(context, acc);
                            }
                          },
                        ),
                        selected: acc.toJson().toString() ==
                            app.item2?.toJson().toString(),
                        onTap: () {
                          Navigator.pop(context);
                          if (acc.configName != app.item2?.configName) {
                            checkAndUseConfig(_parentContext, acc);
                          }
                        },
                      );
                    })),
          ),
          Expanded(
              child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Builder(builder: (context) {
                return ListTile(
                    minLeadingWidth: 10,
                    leading: const Icon(Icons.add),
                    title: const Text('添加新的服务器地址'),
                    onTap: () => Navigator.of(context)
                        .popAndPushNamed("/add_new_aria2_server"));
              }),
              Builder(builder: (context) {
                return ListTile(
                  minLeadingWidth: 10,
                  leading: const Icon(Icons.settings),
                  title: const Text('设置'),
                  onTap: () =>
                      Navigator.of(context).popAndPushNamed("/global_setting"),
                );
              })
            ],
          ))
        ],
      ));
    },
  );
}
