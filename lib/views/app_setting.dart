import 'package:aria_z/l10n/localization_intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/app.dart';

GlobalKey _globalOptionKey = GlobalKey<FormState>();

class AppSettingsWidgets extends StatefulWidget {
  const AppSettingsWidgets({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppSettingsStates();
}

class _AppSettingsStates extends State<AppSettingsWidgets>
    with AutomaticKeepAliveClientMixin<AppSettingsWidgets> {
  late String language;

  @override
  void initState() {
    super.initState();
    language = '简体中文';
  }

  Widget _settingGroupWidget(List<Widget> innerWidgets) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          child: Column(children: innerWidgets),
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AriazLocalizations _l10n =  AriazLocalizations.of(context);
    TextStyle _labelTextStyle =
        const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
    AppState appState = Provider.of<AppState>(context);
    return Form(
        key: _globalOptionKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: [
              _settingGroupWidget([
                Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _l10n.language,
                          style: _labelTextStyle,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: appState.selectedLocale?.toLanguageTag(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onChanged: (String? newValue) {
                              appState.changeLocale(newValue ?? '');
                            },
                            items: appState.localeItems
                                .map<DropdownMenuItem<String>>((LocaleItem lc) {
                              return DropdownMenuItem<String>(
                                value: lc.locale?.toLanguageTag(),
                                child: Text(lc.label),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ]),
                Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(_l10n.themeColor, style: _labelTextStyle),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: appState.appUsingColorName,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onChanged: (String? newValue) {
                              setState(() {
                                appState.changeTheme(appState.appThemeColors
                                    .where((_th) => _th.name == newValue)
                                    .first
                                    .name);
                              });
                            },
                            items: appState.appThemeColors
                                .map<DropdownMenuItem<String>>(
                                    (CustomMateriaColor _theme) {
                              return DropdownMenuItem<String>(
                                value: _theme.name,
                                child: Row(
                                  children: [
                                    Text(_theme.desc),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 80,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          color: _theme.color,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ])
              ]),
              const SizedBox(
                height: 10,
              ),
              _settingGroupWidget([
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(_l10n.refreshDelay, style: _labelTextStyle),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          isExpanded: true,
                          value: appState.intervalSecond.toString(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              appState.updateIntervalSecond(newValue);
                            }
                          },
                          items: <String>['1', '3', '5', '10', '15']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text('$value ${_l10n.second}'),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                )
              ])
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
