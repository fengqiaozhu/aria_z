import 'package:aria2/models/index.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
import 'package:aria_z/l10n/localization_intl.dart';
import 'package:aria_z/states/app.dart';
import 'package:aria_z/states/aria2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Aria2GlobalOptionsWidgets extends StatefulWidget {
  const Aria2GlobalOptionsWidgets({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Aria2GlobalOptionsStates();
}

class _Aria2GlobalOptionsStates extends State<Aria2GlobalOptionsWidgets>
    with AutomaticKeepAliveClientMixin<Aria2GlobalOptionsWidgets> {
  static Aria2Option _newOption = Aria2Option();

  late bool _optionChanged;
  late AriazLocalizations _l10n;

  _checkOptionChange(Map<String, dynamic> _ooMap) {
    Map<String, dynamic> _noMap = _newOption.toJson();
    List<String> _toRemoveKeys = [];
    for (var _k in _noMap.keys) {
      if (_ooMap.containsKey(_k) && _noMap[_k] != _ooMap[_k]) {
        setState(() {
          _optionChanged = true;
        });
      } else {
        _toRemoveKeys.add(_k);
      }
    }
    for (String _k in _toRemoveKeys) {
      _noMap.remove(_k);
    }
    if (_noMap.keys.isEmpty) {
      _optionChanged = false;
    }
    _newOption = Aria2Option.fromJson(_noMap);
  }

  _submitOptionChange() async {
    handleAria2ApiResponse<String>(
        context,
        await Provider.of<AppState>(context, listen: false)
            .aria2!
            .updateTheGlobalOption(_newOption), (res) async {
      handleAria2ApiResponse(
          context,
          await Provider.of<AppState>(context, listen: false)
              .aria2!
              .getAria2GlobalOption(),
          null);
      showCustomSnackBar(context, 1, Text(_l10n.changeGlobalOptionSuccessTip));
    });

    _optionChanged = false;
    _newOption = Aria2Option();
  }

  @override
  void initState() {
    super.initState();
    _optionChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _l10n = AriazLocalizations.of(context);
    Aria2Option _oldOption = Provider.of<Aria2States>(context).globalOption!;

    return Stack(
      children: [
        !_optionChanged
            ? const SizedBox()
            : Card(
                child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 6, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_l10n.optionChangedTip),
                    TextButton.icon(
                        onPressed: _submitOptionChange,
                        icon: const Icon(Icons.send),
                        label: Text(_l10n.submit)),
                  ],
                ),
              )),
        Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(10, _optionChanged ? 70 : 20, 10, 20),
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: _oldOption.dir,
                    onChanged: (v) {
                      _newOption.dir = v.trim();
                      _checkOptionChange(_oldOption.toJson());
                    },
                    validator: (v) => v == null || v.isEmpty
                        ? _l10n.dirInputValidatorText
                        : null,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _l10n.dirInputLabel,
                        contentPadding: const EdgeInsets.all(8)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _oldOption.maxConcurrentDownloads?.toString(),
                    onChanged: (v) {
                      _newOption.maxConcurrentDownloads = int.parse(v.trim());
                      _checkOptionChange(_oldOption.toJson());
                    },
                    validator: (v) {
                      v = v ?? '';
                      if (v.isEmpty) {
                        return _l10n.maxCurrentDownloadValidator_1;
                      }
                      if (v.length > 1 && v.startsWith('0')) {
                        return _l10n.maxCurrentDownloadValidator_2;
                      }

                      if (int.tryParse(v) == null) {
                        return _l10n.maxCurrentDownloadValidator_3;
                      }

                      if (int.parse(v) < 0) {
                        return _l10n.maxCurrentDownloadValidator_4;
                      }
                    },
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _l10n.maxCurrentDownload4,
                        contentPadding: const EdgeInsets.all(8)),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_l10n.ariaContinue),
                      value: _newOption.continue_ == null
                          ? _oldOption.continue_!
                          : _newOption.continue_!,
                      onChanged: (newVal) {
                        setState(() {
                          _newOption.continue_ = newVal;
                          _checkOptionChange(_oldOption.toJson());
                        });
                      }),
                  const SizedBox(height: 10),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_l10n.checkIntegrity),
                      value: _newOption.checkIntegrity == null
                          ? _oldOption.checkIntegrity!
                          : _newOption.checkIntegrity!,
                      onChanged: (newVal) {
                        setState(() {
                          _newOption.checkIntegrity = newVal;
                          _checkOptionChange(_oldOption.toJson());
                        });
                      }),
                  const SizedBox(height: 10),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_l10n.optimizeConcurrentDownloads),
                      value: _newOption.optimizeConcurrentDownloads == null
                          ? _oldOption.optimizeConcurrentDownloads!
                          : _newOption.optimizeConcurrentDownloads!,
                      onChanged: (newVal) {
                        setState(() {
                          _newOption.optimizeConcurrentDownloads = newVal;
                          _checkOptionChange(_oldOption.toJson());
                        });
                      }),
                ],
              ),
            ))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}


// dir 默认下载地址

// max-concurrent-downloads 最大同时下载任务数量 

// max-overall-download-limit 下载速度上限

// max-overall-upload-limit 上传速度上限

// continue 断点续传

// check-integrity 检查完整性

// optimize-concurrent-downloads 优化并行下载

// log 日志文件下载地址

// log-level 日志等级
