import 'package:flutter/material.dart';

GlobalKey _globalOptionKey = GlobalKey<FormState>();

class AppSettingsWidgets extends StatefulWidget {
  const AppSettingsWidgets({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppSettingsStates();
}

class _AppSettingsStates extends State<AppSettingsWidgets>
    with AutomaticKeepAliveClientMixin<AppSettingsWidgets> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
        key: _globalOptionKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.8), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: Text("通用配置"))
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
