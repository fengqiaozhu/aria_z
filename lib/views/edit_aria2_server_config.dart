// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../components/custom_snack_bar.dart';
import '../states/app.dart';

class Aria2ConnectConfigArguments {
  final Aria2ConnectConfig config;
  final int index;

  Aria2ConnectConfigArguments(this.config, this.index);
}

class Aria2ServerEditor extends StatelessWidget {
  const Aria2ServerEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final oldConfig = ModalRoute.of(context)?.settings.arguments
        as Aria2ConnectConfigArguments?;

    void _submitNewServerConfig(context) {
      bodyKey.currentState?.submitServerConfig();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新的服务器配置'),
        actions: [
          IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: '添加新的服务器配置',
              onPressed: () => _submitNewServerConfig(context))
        ],
      ),
      body: SingleChildScrollView(
          child: BodyWidget(
        key: bodyKey,
        oldConfig: oldConfig,
      )),
    );
  }
}

class BodyWidget extends StatefulWidget {
  final Aria2ConnectConfigArguments? oldConfig;

  const BodyWidget({Key? key, this.oldConfig}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BodyWidgetState();
}

GlobalKey<BodyWidgetState> bodyKey = GlobalKey();

class BodyWidgetState extends State<BodyWidget> {
  String host = '';
  String port = '6800';
  String path = '/jsonrpc';
  String protocol = 'http';
  String secret = '';
  String configName = '';
  bool enableHttps = false;
  int? oldIndex;

  @override
  void initState() {
    super.initState();
    Aria2ConnectConfigArguments? oldConfig = widget.oldConfig;
    if (oldConfig != null) {
      Aria2ConnectConfig oc = oldConfig.config;
      host = oc.host;
      port = oc.port;
      path = oc.path;
      protocol = oc.protocol;
      secret = oc.secret;
      configName = oc.configName;
      enableHttps = oc.protocol == 'https' || oc.protocol == 'wss';
      oldIndex = oldConfig.index;
    }
  }

  final GlobalKey _formKey = GlobalKey<FormState>();

  submitServerConfig() {
    String tmpProtocol = '';
    if (enableHttps) {
      tmpProtocol = protocol == 'http' ? 'https' : 'wss';
    } else {
      tmpProtocol = protocol == 'http' ? 'http' : 'ws';
    }
    Map<String, dynamic> serverConfig = {
      'host': host,
      'port': port,
      'path': path,
      'protocol': tmpProtocol,
      'type': protocol,
      'secret': secret,
      'configName': configName,
    };
    if ((_formKey.currentState as FormState).validate()) {
      AppState app = Provider.of<AppState>(context, listen: false);
      String msg = '';
      try {
        if (oldIndex == null) {
          app.addAria2ConnectConfig(Aria2ConnectConfig.fromJson(serverConfig));
          msg = '添加服务配置成功';
        } else {
          app.updateAria2ConnectConfig(
              Aria2ConnectConfig.fromJson(serverConfig), oldIndex!);
          msg = '修改服务配置成功';
        }
        Navigator.pop(context, serverConfig);
        showCustomSnackBar(context, 1, Text(msg));
      } on Exception catch (e) {
        showCustomSnackBar(context, 2, Text(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TextFormField(
                  autofocus: true,
                  controller: TextEditingController(text: configName),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '配置名称',
                      contentPadding: EdgeInsets.all(8)),
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "配置名称不能为空";
                  },
                  onChanged: (v) {
                    configName = v;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text("协议类型"),
                    const SizedBox(width: 18),
                    ToggleSwitch(
                      minWidth: 100,
                      initialLabelIndex: 0,
                      totalSwitches: 2,
                      labels: const ["Http", "Websocket"],
                      onToggle: (index) {
                        protocol = index == 0 ? 'http' : 'websocket';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: TextEditingController(text: host),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '服务器地址',
                      contentPadding: EdgeInsets.all(8)),
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "服务器地址不能为空";
                  },
                  onChanged: (v) {
                    host = v;
                  },
                ),
                const SizedBox(height: 18),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: TextEditingController(text: port),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '端口',
                              contentPadding: EdgeInsets.all(8)),
                          validator: (v) {
                            return v!.trim().isNotEmpty ? null : "端口不能为空";
                          },
                          onChanged: (v) {
                            port = v;
                          },
                        )),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: TextEditingController(text: path),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '路径',
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (v) {
                            path = v;
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                    controller: TextEditingController(text: secret),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '验证令牌',
                        contentPadding: EdgeInsets.all(8)),
                    onChanged: (v) {
                      secret = v;
                    }),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Checkbox(
                        value: enableHttps,
                        onChanged: (val) {
                          setState(() {
                            enableHttps = val ?? false;
                          });
                        }),
                    const Text('启用HTTPS')
                  ],
                )
              ],
            )));
  }
}
