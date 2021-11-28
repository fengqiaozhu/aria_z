import 'package:aria2/aria2.dart';
import 'package:flutter/widgets.dart';

class Aria2States extends ChangeNotifier {
  List<Aria2Task> completedTasks = [];

  List<Aria2Task> downloadingTasks = [];

  List<Aria2Task> waittingTasks = [];

  Aria2GlobalStat globalStatus = Aria2GlobalStat();

  final List<String> _opratingGids = [];

  Aria2States();

  List<Aria2Task> get taskListOfNotComplete {
    return [...downloadingTasks, ...waittingTasks];
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
    gids.map((gid) {
      if (!(_opratingGids.contains(gid))) {
        _opratingGids.add(gid);
      }
    });
    notifyListeners();
  }

  removeOpratingGids(List<String> gids) {
    gids.map((gid) {
      if (_opratingGids.contains(gid)) {
        _opratingGids.remove(gid);
      }
    });
    notifyListeners();
  }
}
