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
    print(Localizations.localeOf(context));
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

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

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
