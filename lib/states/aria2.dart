import 'package:aria2/aria2.dart';
import 'package:flutter/widgets.dart';

enum TaskType { torrent, magnet, url, metaLink }

class NewTaskOption {
  List<String> params;

  TaskType taskType;

  Aria2Option option;

  NewTaskOption(this.taskType, this.params, this.option);
}

class Aria2States extends ChangeNotifier {
  List<Aria2Task> completedTasks = [];

  List<Aria2Task> downloadingTasks = [];

  List<Aria2Task> waittingTasks = [];

  Aria2GlobalStat? globalStatus;

  Aria2Option? globalOption;

  Aria2Version? versionInfo;

  final List<String> _opratingGids = [];

  Aria2States();

  List<Aria2Task> get taskListOfNotComplete {
    List<Aria2Task> list = [...downloadingTasks, ...waittingTasks];
    list = list.map((t) {
      if (_opratingGids.contains(t.gid)) {
        switch (t.status) {
          case 'active':
            t.status = 'pausing';
            break;
          case 'paused':
            t.status = 'unparsing';
            break;
        }
      }
      return t;
    }).toList();
    return list;
  }

  List<String> get opratingGids => _opratingGids;

  updateDownloadingTasks(List<Aria2Task> taskList) {
    downloadingTasks = taskList;
    notifyListeners();
  }

  updateWaittingTasks(List<Aria2Task> taskList) {
    waittingTasks = taskList;
    notifyListeners();
  }

  updateCompletedTasks(List<Aria2Task> taskList) {
    completedTasks = taskList;
    notifyListeners();
  }

  updateGlobalStatus(Aria2GlobalStat stat) {
    globalStatus = stat;
    notifyListeners();
  }

  addOpratingGids(List<String> gids) {
    for (var gid in gids) {
      if (!(_opratingGids.contains(gid))) {
        _opratingGids.add(gid);
      }
    }
    notifyListeners();
  }

  removeOpratingGids(List<String> gids) {
    for (var gid in gids) {
      if (_opratingGids.contains(gid)) {
        _opratingGids.remove(gid);
      }
    }
    notifyListeners();
  }

  updateGlobalOption(options) {
    globalOption = options;
    notifyListeners();
  }

  updateVersion(version) {
    versionInfo = version;
    notifyListeners();
  }

  clearStates() {
    completedTasks = [];
    downloadingTasks = [];
    waittingTasks = [];
    globalStatus = null;
    globalOption = null;
    versionInfo = null;
    _opratingGids.removeRange(0, _opratingGids.length);
    notifyListeners();
  }
}
