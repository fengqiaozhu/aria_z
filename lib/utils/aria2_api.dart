// ignore_for_file: prefer_typing_uninitialized_variables, avoid_init_to_null

import 'dart:async';
import 'package:aria2/aria2.dart';
import '../states/aria2.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

enum Aria2ResponseErrorType { connectionRefused, unauthorized, timeout, other }

enum Aria2ResponseStatus { success, error }

class Aria2Response<T> {
  T? data;

  Aria2ResponseErrorType? error;

  Aria2ResponseStatus status;

  String message;

  Aria2Response(
      {required this.status,
      required this.data,
      required this.error,
      required this.message});
}

class Aria2Client extends Aria2c {
  Aria2States state;

  List<Aria2Task> _downloadingTasks = [];
  List<Aria2Task> _waittingTasks = [];
  List<Aria2Task> _completedTasks = [];
  Aria2GlobalStat _globalStatus = Aria2GlobalStat();
  late List<String> _downloadingGids;
  late Timer? periodicTimer = null;
  late Timer? periodicTimerInner = null;

  Aria2Client(rpcUrl, protocol, secret, this.state)
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
      state.updateCompletedTasks(
          _completedTasks.where((ct) => ct.status != 'removed').toList());
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
    Map<String, dynamic> option = taskOption.option.toJson();
    try {
      switch (taskOption.taskType) {
        case TaskType.torrent:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addTorrent', [p, [], option]);
          }).toList());
          break;
        case TaskType.metaLink:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addMetalink', [p, option]);
          }).toList());
          break;
        case TaskType.magnet:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addUri', [
              [p],
              option
            ]);
          }).toList());
          break;
        case TaskType.url:
          await multicall(taskOption.params.map((p) {
            return Method('aria2.addUri', [
              [p],
              option
            ]);
          }).toList());
          break;
      }
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  /// 获取全局配置
  getAria2GlobalOption() async {
    try {
      var option = await getGlobalOption();
      state.updateGlobalOption(option);
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  Future<Aria2Response<String>> updateTheGlobalOption(Aria2Option option) async {
    return _try2Request(() async {
      return await changeGlobalOption(option);
    });
  }

  getVersionInfo() async {
    try {
      Aria2Version version = await getVersion();
      state.updateVersion(version);
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  /// 删除任务
  /// [gid] 任务gid

  removeTask(String gid) async {
    try {
      await remove(gid);
      await getInfos();
    } on Exception catch (e) {
      return {"status": 0, "error": e};
    }
  }

  Future<Aria2Response<Aria2Client>> checkServerConnection() async {
    return _try2Request(() async {
      await getVersion();
      return this;
    });
  }

  Future<Aria2Response<T>> _try2Request<T>(Function request) async {
    try {
      T data = await request();
      return Aria2Response(
          status: Aria2ResponseStatus.success,
          data: data,
          error: null,
          message: 'OK');
    } on DioError catch (e) {
      String msg;
      Aria2ResponseErrorType errorType;

      switch (e.type) {
        case DioErrorType.response:
          String? dt = e.response?.data;
          if (dt != null && dt.isNotEmpty) {
            Map<String, dynamic> aria2Error = jsonDecode(dt);
            int __errorCode = aria2Error['error']['code'];
            switch (__errorCode) {
              case 1:
                errorType = Aria2ResponseErrorType.unauthorized;
                msg = 'Aria2身份认证失败!';
                break;
              default:
                errorType = Aria2ResponseErrorType.other;
                msg = aria2Error['error']['message'];
                break;
            }
          } else {
            errorType = Aria2ResponseErrorType.other;
            msg = 'Aria2服务器未知错误';
          }
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
          errorType = Aria2ResponseErrorType.timeout;
          msg = '连接服务器超时';
          break;
        case DioErrorType.other:
          var __e = e.error;
          if (__e.runtimeType.toString() == 'SocketException' &&
              __e.osError.runtimeType.toString() == 'OSError') {
            switch (__e.osError.errorCode) {
              case 61:
                errorType = Aria2ResponseErrorType.connectionRefused;
                msg = '连接服务器被拒绝，请检查服务器配置';
                break;
              default:
                errorType = Aria2ResponseErrorType.other;
                msg = __e.osError.message;
                break;
            }
          } else {
            errorType = Aria2ResponseErrorType.other;
            msg = e.message;
          }
          break;
        default:
          errorType = Aria2ResponseErrorType.other;
          msg = e.message;
          break;
      }
      return Aria2Response(
          status: Aria2ResponseStatus.error,
          data: null,
          error: errorType,
          message: msg);
    } on Exception catch (e) {
      return Aria2Response(
          status: Aria2ResponseStatus.error,
          data: null,
          error: Aria2ResponseErrorType.other,
          message: e.toString());
    }
  }
}
