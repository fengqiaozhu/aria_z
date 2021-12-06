import 'package:aria_z/states/app.dart';
import 'package:aria_z/utils/aria2_api.dart'
    show Aria2Client, Aria2Response, Aria2ResponseStatus;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 底部提醒弹框
/// level = 1:成功，2：失败，3：警告
void showCustomSnackBar(BuildContext context, int level, Widget content,
    {int durationSecond = 2}) {
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
  _appState.clearCurrentServerAllState();
  handleAria2ApiResponse<Aria2Client?>(
      context, await _appState.checkAria2ConnectConfig(config), (_client) {
    _appState.connectToAria2Server(_client);
  });
}

/// 处理 aria2 请求结果
handleAria2ApiResponse<T>(BuildContext context, Aria2Response<T> requestResult,
    Function(T)? handler) {
  if (requestResult.status == Aria2ResponseStatus.error) {
    showCustomSnackBar(context, 2, Text(requestResult.message));
  }
  if (handler != null) {
    handler(requestResult.data as T);
  }
}
