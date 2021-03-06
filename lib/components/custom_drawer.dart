import 'package:aria2/aria2.dart';
import 'package:aria2/models/aria2GlobalStat.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:aria_z/components/speed_shower.dart';
import 'package:aria_z/l10n/localization_intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../states/aria2.dart';
import '../states/app.dart';
import '../views/edit_aria2_server_config.dart'
    show Aria2ConnectConfigArguments;

Widget customDrawer(BuildContext _parentContext) {
  AriazLocalizations _l10n = AriazLocalizations.of(_parentContext);
  _deleteServerConfig(BuildContext context, Aria2ConnectConfig config) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_l10n.deleteDialogTitle),
          content: Text(_l10n.deleteDialogContent),
          actions: <Widget>[
            TextButton(
              child: Text(_l10n.cancelBtnText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_l10n.confirmBtnText),
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
                                        ? "${_l10n.connectedText} ${app.item2?.host}:${app.item2?.port}"
                                        : _l10n.notConnectTip,
                                    style: const TextStyle()),
                                serverInfo.item2 != null
                                    ? Text(
                                        "${_l10n.aria2VersionLabel} ${serverInfo.item2?.version ?? ''}",
                                        style: const TextStyle())
                                    : const SizedBox(),
                                serverInfo.item1 == null
                                    ? const SizedBox()
                                    : Chip(
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
                                            child: SpeedShower(
                                                downloadSpeed: serverInfo
                                                    .item1!.downloadSpeed,
                                                uploadSpeed: serverInfo
                                                    .item1!.uploadSpeed)))
                              ],
                            ),
                          )));
                });
          }),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            // ?????? scrollbar ???????????????????????????
            child: Scrollbar(
                child: ListView.builder(
                    // listview ???????????? scrollBar ?????? scrollController????????????????????? listview ?????????scrollController????????????????????????????????????scrollController?????????????????????
                    controller: ScrollController(),
                    // listView ?????????????????????????????????????????????????????????false?????????????????????????????????????????????????????????????????????????????????
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
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(_l10n.editText),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(_l10n.deleteText),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.of(context).popAndPushNamed(
                                  "/update_aria2_server",
                                  arguments: [
                                    Aria2ConnectConfigArguments(acc, idx),
                                    _parentContext
                                  ]);
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
                    title: Text(_l10n.addNewServerConfig),
                    onTap: () => Navigator.of(context).popAndPushNamed(
                        "/add_new_aria2_server",
                        arguments: [null, _parentContext]));
              }),
              Builder(builder: (context) {
                return ListTile(
                  minLeadingWidth: 10,
                  leading: const Icon(Icons.settings),
                  title: Text(_l10n.setting),
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
