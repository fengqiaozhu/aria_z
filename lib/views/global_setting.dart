// ignore_for_file: must_be_immutable

import 'package:aria2/aria2.dart' show Aria2Option;
import 'package:aria_z/l10n/localization_intl.dart';
import 'package:aria_z/states/aria2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'app_setting.dart';
import 'aria2_global_option.dart';
import '../components/custom_snack_bar.dart';

class GlobalSetting extends StatelessWidget {
  const GlobalSetting({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    AriazLocalizations _l10n = AriazLocalizations.of(context);
    final List<Tab> tabs = <Tab>[
    Tab(text: _l10n.appSetting),
    Tab(text:  _l10n.aria2Setting),
  ];
    Aria2Option? _globalOption = Provider.of<Aria2States>(context).globalOption;
    return DefaultTabController(
        length: tabs.length,
        child: Builder(
          builder: (BuildContext context) {
            final TabController tabController =
                DefaultTabController.of(context)!;
            tabController.addListener(() {
              if (tabController.indexIsChanging &&
                  tabController.index == 1 &&
                  _globalOption == null) {
                tabController.index = 0;
                showCustomSnackBar(
                    context, 3,  Text(_l10n.aria2SettingWarning));
              }
            });
            return Scaffold(
              appBar: AppBar(
                title:  Text(_l10n.setting),
                bottom: TabBar(tabs: tabs),
              ),
              body: TabBarView(
                  physics: _globalOption == null
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  children: const <Widget>[
                    AppSettingsWidgets(),
                    Aria2GlobalOptionsWidgets()
                  ]),
            );
          },
        ));
  }
}
