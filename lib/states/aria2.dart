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
    List<Aria2Task> list = [...downloadingTasks, ...waittingTasks];
    list = list.map((t){
      if(_opratingGids.contains(t.gid)){
        switch(t.status){
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
}
