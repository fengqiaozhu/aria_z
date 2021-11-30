// ignore_for_file: unnecessary_this
import 'package:aria_z/components/task_list.dart';
import 'package:provider/provider.dart';
import 'package:aria2/aria2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'utils/tools.dart';
import 'states/aria2.dart';
import 'states/app.dart';
import 'views/edit_aria2_server_config.dart';
import 'views/task_detail.dart';
import 'views/global_setting.dart';
import 'views/add_new_task.dart';
import 'components/custom_drawer.dart';

late final AppState app;
late final Aria2States aria2States;

void main(List<String> args) async {
  await Hive.initFlutter();
  Box aria2ConnectConfigBox = await Hive.openBox('aria2ConnectConfig');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState(aria2ConnectConfigBox)),
      ChangeNotifierProvider(create: (_) => Aria2States()),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainContainer();
  }
}

///*******************body容器，为了设置appbar与body联动 */

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  bool showDownloaded = false;
  late Aria2GlobalStat globalStat;
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
    //初始化状态
    aria2States = Provider.of<Aria2States>(context, listen: false);
    app = Provider.of<AppState>(context, listen: false);
    app.bindAria2States(aria2States);
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle downloadingStyle = TextButton.styleFrom(
        primary: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(fontSize: this.showDownloaded ? 16 : 24));
    final ButtonStyle downloadedStyle = TextButton.styleFrom(
        primary: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(fontSize: this.showDownloaded ? 24 : 16));

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routes: {
        '/global_setting': (context) => GlobalSetting(),
        '/task_detail': (context) => TaskDetail(),
        '/add_new_task': (context) => AddNewAria2Task(),
        '/add_new_aria2_server': (context) => const Aria2ServerEditor(),
        '/update_aria2_server': (context) => const Aria2ServerEditor(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              formatSpeed(Provider.of<Aria2States>(context).globalStatus.downloadSpeed ?? 0)),
          actions: [
            TextButton(
                child: const Text("下载中"),
                style: downloadingStyle,
                onPressed: () => _switchDownloadShowType(false)),
            TextButton(
                child: const Text("已完成"),
                style: downloadedStyle,
                onPressed: () => _switchDownloadShowType(true)),
            Builder(
              builder: (context) {
                return IconButton(
                    icon: const Icon(Icons.add),
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
      ),
    );
  }
}

///******************end */

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
    return Consumer<Aria2States>(builder: (context, aria2State, _) {
      return ListView(
        children: taskListTileWidget(
            context,
            app,
            aria2States,
            widget.showDownloaded
                ? aria2State.completedTasks
                : aria2States.taskListOfNotComplete),
      );
    });
  }
}


///******************end */
