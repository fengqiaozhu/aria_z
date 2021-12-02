// ignore_for_file: unnecessary_this
import 'package:aria_z/components/task_list.dart';
import 'package:provider/provider.dart';
import 'package:aria2/aria2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/tools.dart';
import 'states/aria2.dart';
import 'states/app.dart';
import 'views/edit_aria2_server_config.dart';
import 'views/task_detail.dart';
import 'views/global_setting.dart';
import 'views/add_new_task.dart';
import 'components/custom_drawer.dart';
import 'l10n/localization_intl.dart';

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
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  Locale? localeListResolutionCallback(
      List<Locale>? locales, Iterable<Locale> supportedLocales) {
    print(locales);
    print(supportedLocales.toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<AppState>(context).brightTheme,
      darkTheme: Provider.of<AppState>(context).darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AriazLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: Provider.of<AppState>(context, listen: false)
          .localeItems
          .map((lc) => lc.locale),
      localeListResolutionCallback: localeListResolutionCallback,
      locale: Provider.of<AppState>(context).locale,
      routes: {
        '/global_setting': (context) => const GlobalSetting(),
        '/task_detail': (context) => TaskDetail(),
        '/add_new_task': (context) => const AddNewAria2Task(),
        '/add_new_aria2_server': (context) => const Aria2ServerEditor(),
        '/update_aria2_server': (context) => const Aria2ServerEditor(),
      },
      home: const HomeView(),
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
  late AppState app;

  _switchDownloadShowType(bool newType) {
    setState(() {
      if (this.showDownloaded != newType) {
        this.showDownloaded = !this.showDownloaded;
      }
      if (this.showDownloaded) {
        app.aria2?.getCompletedTasks(0, 50);
      }
    });
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

  @override
  void initState() {
    super.initState();
    showDownloaded = false;
    app = Provider.of<AppState>(context, listen: false);
    app.bindAria2States(Provider.of<Aria2States>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle downloadingStyle = TextButton.styleFrom(
        primary: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(fontSize: this.showDownloaded ? 14 : 16));
    final ButtonStyle downloadedStyle = TextButton.styleFrom(
        primary: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(fontSize: this.showDownloaded ? 16 : 14));
    BitUnit dlSpeedWithUnit = bitToUnit(
        Provider.of<Aria2States>(context).globalStatus.downloadSpeed ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: DefaultTextStyle(
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
        actions: [
          TextButton(
              child: Text(AriazLocalizations.of(context).downloadingBtnText),
              style: downloadingStyle,
              onPressed: () => _switchDownloadShowType(false)),
          TextButton(
              child: Text(AriazLocalizations.of(context).completedBtnText),
              style: downloadedStyle,
              onPressed: () => _switchDownloadShowType(true)),
          Builder(
            builder: (context) {
              return IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 32,
                  tooltip: '添加新任务',
                  onPressed:
                      app.aria2 == null ? null : () => _addNewTask(context));
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
    return Consumer<Aria2States>(builder: (context, aria2State, _) {
      List<Aria2Task> taskList = widget.showDownloaded
          ? aria2State.completedTasks
          : aria2States.taskListOfNotComplete;
      return taskList.isEmpty
          ? Center(
              child: Text('无${widget.showDownloaded ? "已完成" : "下载中"}任务'),
            )
          : ListView(
              children: taskListTileWidget(context,
                  Provider.of<AppState>(context), aria2States, taskList),
            );
    });
  }
}


///******************end */
