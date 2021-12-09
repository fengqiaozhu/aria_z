// ignore_for_file: prefer_typing_uninitialized_variables, avoid_init_to_null

import 'dart:async';
import 'package:aria2/aria2.dart';
import 'package:aria_z/l10n/localization_intl.dart';
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

  List<Aria2Task> _completedTasks = [];
  late List<String> _downloadingGids;
  late Timer? periodicTimer = null;
  late Timer? periodicTimerInner = null;

  final AriazLocalizations _l10n;

  Aria2Client(rpcUrl, protocol, secret, this.state,this._l10n)
      : super(rpcUrl, protocol, secret);

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

  Future<Aria2Response> getInfos() async {
    return _try2Request(() async {
      await _getGlobalStats();
      state.updateDownloadingTasks(await _getDownloadingTasks());
      state.updateWaittingTasks(await _getWaittingTasks());
    });
  }

  Future<Aria2Response> _getGlobalStats() async {
    return _try2Request(() async {
      Aria2GlobalStat _globalStatus = await getGlobalStat();
      state.updateGlobalStatus(_globalStatus);
    });
  }

  Future<Aria2Response> getCompletedTasks(int offset, int limmit) async {
    return _try2Request(() async {
      _completedTasks = await tellStopped(offset, limmit);
      state.updateCompletedTasks(
          _completedTasks.where((ct) => ct.status != 'removed').toList());
    });
  }

  Future<List<Aria2Task>> _getDownloadingTasks() async {
    List<Aria2Task> _downloadingTasks = await tellActive();
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
          return dl.gid!;
        })
        .where((gid) => !state.opratingGids.contains(gid))
        .toList();
    return _downloadingTasks;
  }

  Future<List<Aria2Task>> _getWaittingTasks() async {
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
    return wt;
  }

  Future<Aria2Response> pauseTask(String gid) async {
    return _try2Request(() async {
      state.addOpratingGids([gid]);
      _downloadingGids.remove(gid);
      await pause(gid);
    });
  }

  Future<Aria2Response> unPauseTask(String gid) async {
    return _try2Request(() async {
      state.removeOpratingGids([gid]);
      await unpause(gid);
      await getInfos();
    });
  }

  Future<Aria2Response> pauseAllTask() async {
    return _try2Request(() async {
      state.addOpratingGids(_downloadingGids);
      await pauseAll();
    });
  }

  Future<Aria2Response> unPauseAllTask() async {
    return _try2Request(() async {
      await unpauseAll();
      await getInfos();
    });
  }

  Future<Aria2Response> startWaitingTask(gid) async {
    return _try2Request(() async {
      await changePosition(gid, 0, 'POS_SET');
    });
  }

  Future<Aria2Response> addNewTask(NewTaskOption taskOption) async {
    return _try2Request(() async {
      Map<String, dynamic> option = taskOption.option.toJson();
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
    });
  }

  /// 获取全局配置
  Future<Aria2Response> getAria2GlobalOption() async {
    return _try2Request(() async {
      Aria2Option option = await getGlobalOption();
      state.updateGlobalOption(option);
    });
  }

  Future<Aria2Response<String>> updateTheGlobalOption(Aria2Option option) async {
    return _try2Request(() async {
      return await changeGlobalOption(option);
    });
  }

  Future<Aria2Response> getVersionInfo() async {
    return _try2Request(() async {
      Aria2Version version = await getVersion();
      state.updateVersion(version);
    });
  }

  /// 删除任务
  /// [gid] 任务gid

  Future<Aria2Response> removeTask(String gid) async {
    return _try2Request(() async {
      await remove(gid);
    });
  }

  Future<Aria2Response<Aria2Client>> checkServerConnection() async {
    return _try2Request(() async {
      await getVersion();
      return this;
    });
  }

  Future<Aria2Response<List<Aria2Peer>>> getAria2Peers(String gid) async {
    return _try2Request(() async {
      return await getPeers(gid);
    });
  }

  Future<Aria2Response<T>> _try2Request<T>(Function request) async {
    try {
      T? data = await request();
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
                msg = _l10n.authFailed;
                break;
              default:
                errorType = Aria2ResponseErrorType.other;
                msg = aria2Error['error']['message'];
                break;
            }
          } else {
            errorType = Aria2ResponseErrorType.other;
            msg = _l10n.serverUnknownError;
          }
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
          errorType = Aria2ResponseErrorType.timeout;
          msg = _l10n.timeOutError;
          break;
        case DioErrorType.other:
          var __e = e.error;
          if (__e.runtimeType.toString() == 'SocketException' &&
              __e.osError.runtimeType.toString() == 'OSError') {
            switch (__e.osError.errorCode) {
              case 61:
                errorType = Aria2ResponseErrorType.connectionRefused;
                msg = _l10n.serverRefusedError;
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
