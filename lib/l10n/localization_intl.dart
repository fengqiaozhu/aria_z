import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart'; //1

class AriazLocalizations {
  static Future<AriazLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode!.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    //2
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return AriazLocalizations();
    });
  }

  static AriazLocalizations of(BuildContext context) {
    return Localizations.of<AriazLocalizations>(context, AriazLocalizations) ??
        AriazLocalizations();
  }

  String get downloadingBtnText => Intl.message('Downloading',
      name: 'downloadingBtnText', desc: 'Downloading button text');

  String get completedBtnText => Intl.message('Completed',
      name: 'completedBtnText', desc: 'Completed button text');
}

//Locale代理类
class AriazLocalizationsDelegate
    extends LocalizationsDelegate<AriazLocalizations> {
  const AriazLocalizationsDelegate();

  // 因为将app locale设置提前到material app中，所以这里可以直接置为true
  @override
  bool isSupported(Locale locale) => true;

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<AriazLocalizations> load(Locale locale) {
    //3
    return AriazLocalizations.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(AriazLocalizationsDelegate old) => false;
}
