// ignore_for_file: avoid_init_to_null
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';

import '../utils/aria2_api.dart';
import 'aria2.dart';

class Aria2ConnectConfig {
  String host;

  String port;

  String secret;

  String protocol;

  String type;

  String path;

  String configName;

  Aria2ConnectConfig({
    required this.protocol,
    required this.host,
    required this.port,
    required this.path,
    required this.type,
    required this.configName,
    this.secret = '',
  });

  factory Aria2ConnectConfig.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Aria2ConnectConfig(
      protocol: parsedJson['protocol'],
      host: parsedJson['host'],
      port: parsedJson['port'],
      path: parsedJson['path'],
      type: parsedJson['type'],
      configName: parsedJson['configName'],
      secret: parsedJson['secret'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'protocol': protocol,
      'host': host,
      'port': port,
      'path': path,
      'type': type,
      'secret': secret,
      'configName': configName
    };
  }
}

class Aria2TaskType {
  String desc;

  IconData icon;

  String name;

  TaskType taskType;

  Aria2TaskType(this.name, this.desc, this.icon, this.taskType);
}

class AppState extends ChangeNotifier {
  late Aria2ConnectConfig? _selectedAria2ConnectConfig = null;

  Aria2Client? _client = null;

  Box aria2ConnectConfigBox;

  AppState(this.aria2ConnectConfigBox);

  late final Aria2States states;

  //getters
  Aria2Client? get aria2 => _client;

  Aria2ConnectConfig? get selectedAria2ConnectConfig =>
      _selectedAria2ConnectConfig;

  List<Aria2ConnectConfig> get aria2ConnectConfigs {
    // aria2ConnectConfigBox.deleteAt(0);
    List<Aria2ConnectConfig> tmpList = [];
    aria2ConnectConfigBox.toMap().forEach((key, value) {
      tmpList.add(Aria2ConnectConfig.fromJson(value));
    });
    return tmpList;
  }

  List<Aria2TaskType> get aria2TaskTypes => [
        Aria2TaskType(
            "种子下载", "读取种子文件下载...", Icons.file_present, TaskType.torrent),
        Aria2TaskType("磁力链下载", "输入磁力链接下载...", Icons.link, TaskType.magnet),
        Aria2TaskType("网址下载", "输入Http,Ftp等链接下载...", Icons.web, TaskType.url),
        Aria2TaskType(
            "元数据下载", "输入Metalink下载...", Icons.all_inclusive, TaskType.metaLink),
      ];
  //*********************************************************************************************//

  void bindAria2States(Aria2States state) {
    states = state;
  }

  ///连接到aria2服务器
  connectToAria2Server(url, type, secret) {
    if (url == null || url.isEmpty) {
      return;
    }
    _client?.clearGIInterval();
    _client = Aria2Client(url, type, secret, states);
    _client?.getInfosInterval(2);
    notifyListeners();
  }

  /// 添加连接配置
  addAria2ConnectConfig(Aria2ConnectConfig config) {
    bool isExist = false;
    aria2ConnectConfigBox.toMap().forEach((key, value) {
      if (value['configName'] == config.configName) {
        isExist = true;
      }
    });
    if (isExist) {
      throw Exception('已存在同名连接配置');
    }
    aria2ConnectConfigBox.add(config.toJson());
    useAria2ConnectConfig(config);
  }

  /// 删除连接配置
  removeAria2ConnectConfig(Aria2ConnectConfig config) {
    aria2ConnectConfigBox.toMap().forEach((key, value) {
      if (value['configName'] == config.configName) {
        if (config.configName == selectedAria2ConnectConfig?.configName) {
          _client?.clearGIInterval();
          _client = null;
        }
        aria2ConnectConfigBox.delete(key);
      }
    });
    notifyListeners();
  }

  /// 更新连接配置
  updateAria2ConnectConfig(Aria2ConnectConfig config, int idx) {
    aria2ConnectConfigBox.putAt(idx, config.toJson());
    notifyListeners();
  }

  /// 使用连接配置
  useAria2ConnectConfig(Aria2ConnectConfig config) {
    if (config.configName != selectedAria2ConnectConfig?.configName) {
      connectToAria2Server(
          '${config.protocol}://${config.host}:${config.port}${config.path}',
          config.type,
          config.secret);
      _selectedAria2ConnectConfig = config;
      notifyListeners();
    }
  }
}
