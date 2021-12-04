// ignore_for_file: avoid_init_to_null
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class CustomMateriaColor {
  MaterialColor color;

  String desc;

  String name;

  CustomMateriaColor(this.name, this.color, this.desc);
}

class LocaleItem {
  String label;

  Locale? locale;

  LocaleItem(this.locale, this.label);
}

class AppState extends ChangeNotifier {
  AppState(this.aria2ConnectConfigBox, this.prefs);

  /// hiveBox容器
  Box aria2ConnectConfigBox;

  /// shared_preferences容器
  SharedPreferences prefs;

  /// 选择连接的服务器配置
  late Aria2ConnectConfig? _selectedAria2ConnectConfig = null;

  /// aria2连接实例化
  Aria2Client? _client = null;

  /// aria2 请求结构缓存状态
  late final Aria2States states;

  /// 是否正在检查服务器配置
  bool checkingConfig = false;

  //getters
  /// 本地化
  Locale? get selectedLocale {
    String? _l = prefs.getString('userSelectedLocaleLanguageTag');
    if (_l != null) {
      List<String> languageTag = _l.split('-');
      return Locale.fromSubtags(
          languageCode: languageTag.first,
          scriptCode: languageTag.length == 3 ? languageTag[1] : null,
          countryCode: languageTag.last);
    }
  }

  String get appUsingColorName => prefs.getString('primaryColor') ?? 'green';

  int get intervalSecond => prefs.getInt('intervalSecond') ?? 3;

  ThemeData get brightTheme => ThemeData(
      primarySwatch: appThemeColors
          .where((_color) => _color.name == appUsingColorName)
          .first
          .color,
      brightness: Brightness.light);
  ThemeData get darkTheme => ThemeData(
      primarySwatch: appThemeColors
          .where((_color) => _color.name == appUsingColorName)
          .first
          .color,
      brightness: Brightness.dark);

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

  List<CustomMateriaColor> get appThemeColors => [
        CustomMateriaColor('blue', Colors.blue, "蓝色"),
        CustomMateriaColor('red', Colors.red, "红色"),
        CustomMateriaColor('green', Colors.green, "绿色"),
        CustomMateriaColor('purple', Colors.purple, "紫色"),
      ];

  List<LocaleItem> get localeItems => [
        LocaleItem(null, "系统语言"),
        LocaleItem(const Locale('en', 'US'), 'English'),
        LocaleItem(
            const Locale.fromSubtags(
                languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
            '简体中文')
      ];
  //*********************************************************************************************//

  void bindAria2States(Aria2States state) {
    states = state;
  }

  ///连接到aria2服务器
  connectToAria2Server(Aria2Client? newClient) async {
    _client = newClient;
    if (_client != null) {
      _client?.getAria2GlobalOption();
      _client?.getVersionInfo();
      _client?.getInfosInterval(intervalSecond);
    }
    notifyListeners();
  }

  // 清理当前服务器所有的状态
  clearCurrentServerAllState() {
    _client?.clearGIInterval();
    states.clearStates();
  }

  /// 添加连接配置
  bool addAria2ConnectConfig(Aria2ConnectConfig config) {
    bool isExist = false;
    aria2ConnectConfigBox.toMap().forEach((key, value) {
      if (value['configName'] == config.configName) {
        isExist = true;
      }
    });
    if (isExist) {
      return false;
    }
    aria2ConnectConfigBox.add(config.toJson());
    return true;
  }

  Future<Aria2Response<Aria2Client>> checkAria2ConnectConfig(
      Aria2ConnectConfig config) async {
    _selectedAria2ConnectConfig = config;
    checkingConfig = true;
    notifyListeners();
    Aria2Client __client = Aria2Client(
        '${config.protocol}://${config.host}:${config.port}${config.path}',
        config.type,
        config.secret,
        states);
    Aria2Response<Aria2Client> checkResult =
        await __client.checkServerConnection();
    checkingConfig = false;    
    notifyListeners();
    return checkResult;
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

  changeTheme(String _colorName) {
    prefs.setString('primaryColor', _colorName);
    notifyListeners();
  }

  /// 更新刷新aria2服务访问频率
  void updateIntervalSecond(String second) {
    int _intervalSecond = int.parse(second);
    _client?.clearGIInterval();
    _client?.getInfosInterval(_intervalSecond);
    prefs.setInt('intervalSecond', _intervalSecond);
    notifyListeners();
  }

  void changeLocale(String languageCode) {
    if (languageCode.isEmpty) {
      prefs.remove('userSelectedLocaleLanguageTag');
    } else {
      prefs.setString('userSelectedLocaleLanguageTag', languageCode);
    }
    notifyListeners();
  }
}
