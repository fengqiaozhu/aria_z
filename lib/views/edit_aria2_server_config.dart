// ignore_for_file: must_be_immutable

import 'package:aria_z/l10n/localization_intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../components/custom_snack_bar.dart';
import '../states/app.dart';

late AriazLocalizations _l10n;

class Aria2ConnectConfigArguments {
  final Aria2ConnectConfig config;
  final int index;

  Aria2ConnectConfigArguments(this.config, this.index);
}

class Aria2ServerEditor extends StatelessWidget {
  const Aria2ServerEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Aria2ConnectConfigArguments? oldConfig;
    BuildContext? homePageContext;
    _l10n = AriazLocalizations.of(context);
    var args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      args = args as List<dynamic>;
      oldConfig = args[0] as Aria2ConnectConfigArguments?;
      homePageContext = args[1] as BuildContext;
    }

    void _submitNewServerConfig(context) {
      bodyKey.currentState?.submitServerConfig();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.addNewServerConfig),
        actions: [
          IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: _l10n.addNewServerConfig,
              onPressed: () => _submitNewServerConfig(context))
        ],
      ),
      body: SingleChildScrollView(
          child: BodyWidget(
        key: bodyKey,
        oldConfig: oldConfig,
        homePageContext: homePageContext,
      )),
    );
  }
}

class BodyWidget extends StatefulWidget {
  final Aria2ConnectConfigArguments? oldConfig;

  final BuildContext? homePageContext;

  const BodyWidget({Key? key, this.oldConfig, this.homePageContext})
      : super(key: key);

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
      protocol = oc.type;
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
      Aria2ConnectConfig newConfig = Aria2ConnectConfig.fromJson(serverConfig);
      if (oldIndex == null) {
        bool isNotExist = app.addAria2ConnectConfig(newConfig);
        if (isNotExist) {
          checkAndUseConfig(widget.homePageContext!, newConfig);
        } else {
          showCustomSnackBar(context, 2, Text(_l10n.confitExists));
          return;
        }
        msg = _l10n.addConfigSuccessTip;
      } else {
        app.updateAria2ConnectConfig(newConfig, oldIndex!);
        checkAndUseConfig(widget.homePageContext!, newConfig);
        msg = _l10n.updateConfigSuccessTip;
      }
      showCustomSnackBar(context, 1, Text(msg), durationSecond: 1);
      Navigator.pop(context, serverConfig);
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
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _l10n.configName,
                      contentPadding: const EdgeInsets.all(8)),
                  validator: (v) {
                    return v!.trim().isNotEmpty
                        ? null
                        : _l10n.configNameValidatorText_1;
                  },
                  onChanged: (v) {
                    configName = v;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(_l10n.protocol),
                    const SizedBox(width: 18),
                    ToggleSwitch(
                      activeBgColor: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ],
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
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _l10n.host,
                      contentPadding: const EdgeInsets.all(8)),
                  validator: (v) {
                    return v!.trim().isNotEmpty
                        ? null
                        : _l10n.hostValidatorText_1;
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
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: _l10n.port,
                              contentPadding: const EdgeInsets.all(8)),
                          validator: (v) {
                            return v!.trim().isNotEmpty
                                ? null
                                : _l10n.portValidatorText_1;
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
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: _l10n.path,
                            contentPadding: const EdgeInsets.all(8),
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
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _l10n.secret,
                        contentPadding: const EdgeInsets.all(8)),
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
                    Text(_l10n.enableHttps),
                  ],
                )
              ],
            )));
  }
}
