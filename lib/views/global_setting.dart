// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'app_setting.dart';
import 'aria2_global_option.dart';

class GlobalSetting extends StatelessWidget {
  const GlobalSetting({Key? key}) : super(key: key);

  static const List<Tab> tabs = <Tab>[
    Tab(text: 'APP设置'),
    Tab(text: 'Aria2全局配置'),
  ];
  @override
  Widget build(BuildContext context) {
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
                title: const Text('设置'),
                bottom: const TabBar(tabs: tabs),
              ),
              body: const TabBarView(children: [
                AppSettingsWidgets(),
                Aria2GlobalOptionsWidgets()
              ]),
            );
          },
        ));
  }
}
