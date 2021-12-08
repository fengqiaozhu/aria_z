import 'package:aria2/models/index.dart';
import 'package:aria_z/components/custom_snack_bar.dart';
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
      showCustomSnackBar(context, 1, const Text('修改全局配置成功'));
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
    Aria2Option _oldOption = Provider.of<Aria2States>(context).globalOption!;
    super.build(context);

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
                    const Text('配置已发生改变，点击右侧按钮提交'),
                    TextButton.icon(
                        onPressed: _submitOptionChange,
                        icon: const Icon(Icons.send),
                        label: const Text('提交')),
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
                      _newOption.dir = v;
                      _checkOptionChange(_oldOption.toJson());
                    },
                    validator: (v) => v == null || v.isEmpty ? '请输入下载目录' : null,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '默认下载地址',
                        contentPadding: EdgeInsets.all(8)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _oldOption.maxConcurrentDownloads?.toString(),
                    onChanged: (v) {
                      _newOption.maxConcurrentDownloads = int.parse(v);
                      _checkOptionChange(_oldOption.toJson());
                    },
                    validator: (v) {
                      v = v ?? '';
                      if (v.isEmpty) {
                        return '请输入数量';
                      }
                      if (v.length > 1 && v.startsWith('0')) {
                        return '下载数不能以0开头';
                      }

                      if (int.tryParse(v) == null) {
                        return '请输入合法整数';
                      }

                      if (int.parse(v) < 0) {
                        return '最小同时下载数量需大于等于1';
                      }
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '最大同时下载任务数量 ',
                        contentPadding: EdgeInsets.all(8)),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("断点续传"),
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
                      title: const Text("检查完整性"),
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
                      title: const Text("优化并行下载"),
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
