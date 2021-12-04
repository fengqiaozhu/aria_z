import 'package:aria_z/states/app.dart';
import 'package:aria_z/utils/aria2_api.dart'
    show Aria2ResponseStatus, Aria2Response;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 底部提醒弹框
/// level = 1:成功，2：失败，3：警告
void showCustomSnackBar(BuildContext context, int level, Widget content,
    {int durationSecond = 1}) {
  Color bg = Colors.grey;

  switch (level) {
    case 1:
      bg = Colors.green;
      break;
    case 2:
      bg = Colors.red;
      break;
    case 3:
      bg = Colors.orange;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: durationSecond),
      content: content,
      backgroundColor: bg,
    ),
  );
}

checkAndUseConfig(BuildContext context, Aria2ConnectConfig config) async {
  AppState _appState = Provider.of<AppState>(context, listen: false);
  if (_appState.selectedAria2ConnectConfig?.configName != config.configName) {
    _appState.clearCurrentServerAllState();
    Aria2Response checkResult = await _appState.checkAria2ConnectConfig(config);
    if (checkResult.status == Aria2ResponseStatus.error) {
      showCustomSnackBar(context, 2, Text(checkResult.message));
    }
    _appState.connectToAria2Server(checkResult.data);
  }
}
