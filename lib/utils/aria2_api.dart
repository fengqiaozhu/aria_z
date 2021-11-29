// ignore_for_file: prefer_typing_uninitialized_variables, avoid_init_to_null

import 'dart:async';
import 'package:aria2/aria2.dart';
import '../states/app.dart' show TaskType;
import '../states/aria2.dart';

class Aria2Client extends Aria2c {
  String protocol;

  String rpcUrl;

  String secret;

  Aria2States state;

  List<Aria2Task> _downloadingTasks = [];
  List<Aria2Task> _waittingTasks = [];
  List<Aria2Task> _completedTasks = [];
  Aria2GlobalStat _globalStatus = Aria2GlobalStat();
  late List<String> _downloadingGids;
  late Timer? periodicTimer = null;
  late Timer? periodicTimerInner = null;

  Aria2Client(this.rpcUrl, this.protocol, this.secret, this.state)
      : super(rpcUrl, protocol, secret);

  List<Aria2Task> get downloadingTasks {
    return _downloadingTasks;
  }

  List<Aria2Task> get waittingTasks {
    return _waittingTasks;
  }

  Aria2GlobalStat get globalStatus {
    return _globalStatus;
  }

  getInfosInterval(int timeIntervalSecend) {
    getInfos();
    Duration timeout = Duration(seconds: timeIntervalSecend);
    periodicTimer = Timer.periodic(timeout, (timer) async {
      periodicTimerInner = timer;
      getInfos();
    });
  }

  clearGIInterval() {
    periodicTimerInner?.cancel();
    periodicTimer?.cancel();
  }

  getInfos() async {
    await _getGlobalStats();
    await _getDownloadingTasks();
    await _getWaittingTasks();
    state.updateDownloadingTasks(_downloadingTasks);
    state.updateWaittingTasks(_waittingTasks);
    state.updateGlobalStatus(_globalStatus);
  }

  getCompletedTasks(int offset, int limmit) async {
    try {
      _completedTasks = await tellStopped(offset, limmit);
      state.updateCompletedTasks(_completedTasks);
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  _getGlobalStats() async {
    try {
      _globalStatus = await getGlobalStat();
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  _getDownloadingTasks() async {
    try {
      _downloadingTasks = await tellActive();
      // 暂停任务指令不会立即生效，所以手动改变任务状态
      for (var i = 0; i < _downloadingTasks.length; i++) {
        if (state.opratingGids.contains(_downloadingTasks[i].gid)) {
          if (_downloadingTasks[i].status == 'active') {
            _downloadingTasks.add(_downloadingTasks.removeAt(i));
          } else {
            state.removeOpratingGids([_downloadingTasks[i].gid ?? ""]);
          }
        }
      }
      _downloadingGids = _downloadingTasks
          .map((dl) {
            return dl.gid ?? '';
          })
          .where((gid) => gid != '' && !state.opratingGids.contains(gid))
          .toList();
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  _getWaittingTasks() async {
    int size = 1;
    Future<List<Aria2Task>> _getWT(
        int offset, int _num, List<Aria2Task> li) async {
      List<Aria2Task> tmp = await tellWaiting(offset, _num);
      li.addAll(tmp);
      if (tmp.length == _num) {
        await _getWT(offset + _num, _num, li);
      }
      return li;
    }

    try {
      List<Aria2Task> wt = await _getWT(0, size, []);
      for (var i = 0; i < wt.length; i++) {
        if (wt[i].status == 'waiting' &&
            !(_downloadingGids.contains(wt[i].gid))) {
          _downloadingGids.add(wt[i].gid!);
        }
        if (state.opratingGids.contains(wt[i].gid) &&
            ['paused', 'waiting'].contains(wt[i].status)) {
          state.removeOpratingGids([wt[i].gid ?? ""]);
        }
      }
      _waittingTasks = wt;
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  pauseTask(String gid) async {
    try {
      state.addOpratingGids([gid]);
      _downloadingGids.remove(gid);
      await pause(gid);
    } on Exception catch (e) {
      return {"status": 0, "gid": gid, "error": e};
    }
  }

  unPauseTask(String gid) async {
    try {
      state.removeOpratingGids([gid]);
      await unpause(gid);
      await getInfos();
    } on Exception catch (e) {
      return {"status": 0, "gid": gid, "error": e};
    }
  }

  pauseAllTask() async {
    try {
      state.addOpratingGids(_downloadingGids);
      await pauseAll();
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  unPauseAllTask() async {
    try {
      await unpauseAll();
      await getInfos();
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  startWaitingTask(gid) async {
    try {
      await changePosition(gid, 0, 'POS_SET');
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  addNewTask(NewTaskOption taskOption) async {
    try {
      switch (taskOption.taskType) {
        case TaskType.torrent:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addTorrent', [p]);
          }).toList());
          break;
        case TaskType.metaLink:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addMetalink', [p]);
          }).toList());
          break;
        case TaskType.magnet:
          break;
        case TaskType.url:
          break;
      }
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }
}
