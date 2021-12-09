// ignore_for_file: unnecessary_this
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:aria_z/components/task_list.dart';
import 'package:provider/provider.dart';
import 'package:aria2/aria2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'utils/tools.dart';
import 'states/aria2.dart';
import 'states/app.dart';
import 'views/edit_aria2_server_config.dart';
import 'views/task_detail.dart';
import 'views/global_setting.dart';
import 'views/add_new_task.dart';
import 'components/custom_drawer.dart';
import 'l10n/localization_intl.dart';

final GlobalKey speedLimitFormKey = GlobalKey<FormState>();
GlobalKey<_SpeedControlState> speedControlKey = GlobalKey();
GlobalKey<_HomeViewState> homeViewKey = GlobalKey();
late AriazLocalizations _l10n;
late AppState app;
bool stateInited = false;

void main(List<String> args) async {
  await Hive.initFlutter();
  Box aria2ConnectConfigBox = await Hive.openBox('aria2ConnectConfig');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => AppState(aria2ConnectConfigBox, prefs)),
      ChangeNotifierProvider(create: (_) => Aria2States()),
    ],
    child: App(),
  ));
}

// ignore: must_be_immutable
class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  bool localeListResolutionCallbackEmited = false;

  Locale? localeListResolutionCallback(Locale? selectedLocale,
      List<Locale>? locales, Iterable<Locale> supportedLocales) {
    if (!localeListResolutionCallbackEmited) {
      Locale? deviceLocale = selectedLocale ?? locales?[0];
      if (deviceLocale != null) {
        String localeTag = deviceLocale.toString();
        if (!supportedLocales
            .map<String>((sl) => sl.toString())
            .contains(localeTag)) {
          Locale? _tmp = const Locale('en', 'US');
          for (var _sl in supportedLocales) {
            if (_sl.languageCode == deviceLocale.languageCode) {
              _tmp = _sl;
              break;
            }
          }
          return _tmp;
        } else {
          return deviceLocale;
        }
      }
      return const Locale('en', 'US');
    }
    localeListResolutionCallbackEmited = !localeListResolutionCallbackEmited;
  }

  @override
  Widget build(BuildContext context) {
    if (!stateInited) {
      _l10n = AriazLocalizations.of(context);
      app = Provider.of<AppState>(context, listen: false);
      app.bindAria2States(Provider.of<Aria2States>(context, listen: false));
      app.bindL10n(_l10n);
      stateInited = true;
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        theme: Provider.of<AppState>(context).brightTheme,
        darkTheme: Provider.of<AppState>(context).darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AriazLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          // 此处解决ios复制粘贴功能无法使用问题
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeListResolutionCallback:
            (List<Locale>? locales, Iterable<Locale> supportedLocales) =>
                localeListResolutionCallback(
                    Provider.of<AppState>(context).selectedLocale,
                    locales,
                    supportedLocales),
        supportedLocales: Provider.of<AppState>(context, listen: false)
            .localeItems
            .where((lc) => lc.locale != null)
            .map((lc) => lc.locale!),
        locale: Provider.of<AppState>(context).selectedLocale,
        routes: {
          '/global_setting': (context) => const GlobalSetting(),
          '/task_detail': (context) => TaskDetail(),
          '/add_new_task': (context) => const AddNewAria2Task(),
          '/add_new_aria2_server': (context) => const Aria2ServerEditor(),
          '/update_aria2_server': (context) => const Aria2ServerEditor(),
        },
        home: HomeView(key: homeViewKey),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late bool showDownloaded;

  void _switchDownloadShowType(bool newType) async {
    if (this.showDownloaded != newType) {
      setState(() {
        this.showDownloaded = !this.showDownloaded;
      });
      if (this.showDownloaded && app.aria2 != null) {
        handleAria2ApiResponse(
            context, await app.aria2!.getCompletedTasks(0, 50), null);
      }
    }
  }

  void _showSpeedLimitDialog(AppState app) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.speed),
              const SizedBox(width: 8),
              Text(_l10n.setSpeedLimitTitle)
            ],
          ),
          content: SizedBox(
            height: 210,
            child: SpeedControlWidgt(key: speedControlKey),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(_l10n.applyBtnText),
              onPressed: () async {
                if ((speedLimitFormKey.currentState as FormState).validate()) {
                  handleAria2ApiResponse(
                      context,
                      await app.aria2!.updateTheGlobalOption(
                          speedControlKey.currentState!.speedOption),
                      (data) async {
                    showCustomSnackBar(
                        context, 1, Text(_l10n.speedLimitSetSuccess));
                    handleAria2ApiResponse(
                        context, await app.aria2!.getAria2GlobalOption(), null);
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewTask(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 300,
              // color: Colors,
              child: Center(
                  child: ListView(
                      children: app.aria2TaskTypes.map((att) {
                return ListTile(
                  title: Text(att.name),
                  leading: Icon(att.icon),
                  subtitle: Text(att.desc),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .pushNamed('/add_new_task', arguments: att);
                  },
                );
              }).toList())));
        });
  }

  ButtonStyle downloadSwitchBtnStyle(bool _isDownloadingBtn) {
    return TextButton.styleFrom(
        primary: _isDownloadingBtn == showDownloaded
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(
            fontSize: _isDownloadingBtn == showDownloaded ? 16 : 18,
            fontWeight: _isDownloadingBtn == showDownloaded
                ? FontWeight.w400
                : FontWeight.w600));
  }

  @override
  void initState() {
    super.initState();
    showDownloaded = false;
  }

  @override
  Widget build(BuildContext context) {
    Aria2States _as = Provider.of<Aria2States>(context);
    BitUnit dlSpeedWithUnit = bitToUnit(_as.globalStatus?.downloadSpeed ?? 0);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        title: TextButton(
            onPressed: () =>
                _as.globalOption != null ? _showSpeedLimitDialog(app) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DefaultTextStyle(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    child: Text.rich(TextSpan(
                      children: [
                        TextSpan(
                            text: dlSpeedWithUnit.bit,
                            style: const TextStyle(
                                fontFamily: 'Coda',
                                fontSize: 28,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: ' ${dlSpeedWithUnit.unit}b/s',
                            style: const TextStyle(
                              fontFamily: 'Coda',
                              fontSize: 14,
                            ))
                      ],
                    ))),
                _as.globalOption != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _as.globalOption == null ||
                                  _as.globalOption?.maxOverallDownloadLimit == 0
                              ? const SizedBox()
                              : Icon(
                                  Icons.speed,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        ],
                      )
                    : const SizedBox()
              ],
            )),
        // bottom: PreferredSize(
        //     child: TaskRetrieval(
        //       showDownloaded: showDownloaded,
        //     ),
        //     preferredSize: const Size.fromHeight(64)),
        actions: [
          TextButton(
              child: Text(_l10n.downloadingBtnText),
              style: downloadSwitchBtnStyle(true),
              onPressed: () => _switchDownloadShowType(false)),
          TextButton(
              child: Text(_l10n.completedBtnText),
              style: downloadSwitchBtnStyle(false),
              onPressed: () => _switchDownloadShowType(true)),
          // IconButton(
          //     icon: const Icon(Icons.search),
          //     iconSize: 24,
          //     tooltip: '添加新任务',
          //     onPressed: () => _switchDownloadShowType(true)),
          Builder(
            builder: (context) {
              return IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 32,
                  tooltip: _l10n.addNewTaskToolTip,
                  onPressed: Provider.of<AppState>(context).aria2 == null
                      ? null
                      : () => _addNewTask(context));
            },
          )
        ],
      ),
      drawer: customDrawer(context),
      body: Center(
        child: BodyWidget(
          showDownloaded: showDownloaded,
        ),
      ),
    );
  }
}

// class TaskRetrieval extends StatefulWidget {
//   final bool showDownloaded;

//   const TaskRetrieval({Key? key, required this.showDownloaded})
//       : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _TaskRetrievalState();
// }

// class _TaskRetrievalState extends State<TaskRetrieval> {
//   late String searchInput;

//   @override
//   void initState() {
//     super.initState();
//     searchInput = '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(8),
//         child: Flex(
//           direction: Axis.horizontal,
//           children: [
//             Expanded(
//               child: TextField(
//                 autofocus: false,
//                 controller: TextEditingController(text: searchInput),
//                 onChanged: (v) => searchInput = v,
//                 decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Theme.of(context).colorScheme.surface,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(24))),
//                     contentPadding: const EdgeInsets.all(8)),
//               ),
//             )
//           ],
//         ));
//   }
// }

class SpeedControlWidgt extends StatefulWidget {
  const SpeedControlWidgt({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpeedControlState();
}

class _SpeedControlState extends State<SpeedControlWidgt> {
  late BitUnit _maxDownloadSpeed;
  late BitUnit _maxUploadSpeed;
  late Aria2States _as;

  /// 验证下载速度是否合法
  speedLimitInputValidator(String number) {
    if (number.isEmpty) {
      return _l10n.speedLimitInputValidatorText_1;
    }
    if (number.length > 1 && number.startsWith('0')) {
      return _l10n.speedLimitInputValidatorText_2;
    }
    return double.tryParse(number) == null
        ? _l10n.speedLimitInputValidatorText_3
        : null;
  }

  @override
  void initState() {
    super.initState();
    _as = Provider.of<Aria2States>(context, listen: false);
    _maxDownloadSpeed = bitToUnit(_as.globalOption!.maxOverallDownloadLimit!);
    _maxUploadSpeed = bitToUnit(_as.globalOption!.maxOverallUploadLimit!);
  }

  Aria2Option get speedOption => Aria2Option.fromJson({
        "max-overall-download-limit": unitToBit(_maxDownloadSpeed).round(),
        "max-overall-upload-limit": unitToBit(_maxUploadSpeed).round()
      });

  @override
  Widget build(BuildContext context) {
    return Form(
        key: speedLimitFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: <Widget>[
          TextFormField(
            controller: TextEditingController(text: _maxDownloadSpeed.bit),
            onChanged: (v) => _maxDownloadSpeed.bit = v,
            validator: (v) => speedLimitInputValidator(v ?? ''),
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _l10n.maxDonwloadSpeedInputLabel,
                helperText: _l10n.maxSpeedInputHelper,
                contentPadding: const EdgeInsets.all(8),
                suffix: DropdownButtonHideUnderline(
                    child: DropdownButton(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  value: _maxDownloadSpeed.unit,
                  onChanged: (String? newVal) {
                    setState(() {
                      _maxDownloadSpeed.unit = newVal!;
                    });
                  },
                  items: <String>["", "K", "M"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value + 'B/s'),
                    );
                  }).toList(),
                ))),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: TextEditingController(text: _maxUploadSpeed.bit),
            onChanged: (v) => _maxUploadSpeed.bit = v,
            validator: (v) => speedLimitInputValidator(v ?? ''),
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _l10n.maxUploadSpeedInputLabel,
                helperText: _l10n.maxSpeedInputHelper,
                contentPadding: const EdgeInsets.all(8),
                suffix: DropdownButtonHideUnderline(
                    child: DropdownButton(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  value: _maxUploadSpeed.unit,
                  onChanged: (String? newVal) {
                    setState(() {
                      _maxUploadSpeed.unit = newVal!;
                    });
                  },
                  items: <String>["", "K", "M"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value + 'B/s'),
                    );
                  }).toList(),
                ))),
          )
        ]));
  }
}

///******************Body渲染 */

class BodyWidget extends StatefulWidget {
  final bool showDownloaded;

  const BodyWidget({Key? key, this.showDownloaded = false}) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  late String versionInfo = "";
  late String globalstat = "";
  late List<Aria2Task> tasksOfDownloading = [];
  late List<Aria2Task> tasksOfCompleted = [];
  late List<Aria2Task> tasksOfWaiting = [];

  @override
  Widget build(BuildContext context) {
    Aria2States aria2States = Provider.of<Aria2States>(context);
    AppState app = Provider.of<AppState>(context);
    return Consumer<Aria2States>(builder: (context, aria2State, _) {
      List<Aria2Task> taskList = widget.showDownloaded
          ? aria2State.completedTasks
          : aria2States.taskListOfNotComplete;
      if (app.checkingConfig) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitDoubleBounce(
                color: app.appThemeColors
                    .where((_color) => _color.name == app.appUsingColorName)
                    .first
                    .color,
                size: 50.0,
              ),
              Text(_l10n.connecttingTip)
            ],
          ),
        );
      } else {
        return app.aria2 == null
            ? Center(
                child: app.selectedAria2ConnectConfig == null
                    ? Text(_l10n.notConnectTip)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_l10n.connectFailedTip),
                          TextButton(
                              child: Text(_l10n.reConnectBtnText),
                              onPressed: () {
                                checkAndUseConfig(
                                    context, app.selectedAria2ConnectConfig!);
                              })
                        ],
                      ))
            : (taskList.isEmpty
                ? Center(
                    child: Text(
                        '${_l10n.noText}${widget.showDownloaded ? _l10n.completeTipText : _l10n.downloadingTipText}${_l10n.taskText}'),
                  )
                : ListView(
                    children: taskListTileWidget(context,
                        Provider.of<AppState>(context), aria2States, taskList),
                  ));
      }
    });
  }
}


///******************end */
