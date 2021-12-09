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

  String get downloadingBtnText => Intl.message('Download',
      name: 'downloadingBtnText', desc: 'Downloading button text');

  String get completedBtnText => Intl.message('Complete',
      name: 'completedBtnText', desc: 'Completed button text');

  String get setSpeedLimitTitle => Intl.message('Set speed limit',
      name: 'setSpeedLimitTitle', desc: 'Set Speed Limit dialog Title');

  String get speedLimitSetSuccess => Intl.message('Success to set speed limit',
      name: 'speedLimitSetSuccess', desc: 'Speed limit set success tip');

  String get addNewTaskToolTip => Intl.message('Add new task',
      name: 'addNewTaskToolTip', desc: 'Add new task icon button toolTip');

  String get speedLimitInputValidatorText_1 =>
      Intl.message('Please input speed limit',
          name: 'speedLimitInputValidatorText_1',
          desc: 'Speed limit input validatator text');

  String get speedLimitInputValidatorText_2 =>
      Intl.message('Speed limit cannot start with 0',
          name: 'speedLimitInputValidatorText_2',
          desc: 'Speed limit input validatator text');

  String get speedLimitInputValidatorText_3 =>
      Intl.message('Speed limit must be a number',
          name: 'speedLimitInputValidatorText_3',
          desc: 'Speed limit input validatator text');

  String get maxDonwloadSpeedInputLabel =>
      Intl.message('Max over all download speed limit',
          name: 'maxDonwloadSpeedInputLabel',
          desc: 'Max donwload speed input label text');

  String get maxUploadSpeedInputLabel => Intl.message('Max over all upload speed limit',
      name: 'maxUploadSpeedInputLabel',
      desc: 'Max upload speed input label text');

  String get maxSpeedInputHelper => Intl.message('Set to 0 means no limit',
      name: 'maxSpeedInputHelper', desc: 'Max speed input helper');

  String get connecttingTip => Intl.message('Trying to connect Aria2 server',
      name: 'connecttingTip', desc: 'Connectting aria2 server Tip');

  String get connectFailedTip =>
      Intl.message('Failed to connect to Aria2 server...',
          name: 'connectFailedTip', desc: 'Connect Failed Tip');

  String get notConnectTip => Intl.message('Not connect to a Aria2 server now',
      name: 'notConnectTip', desc: 'Not connect tip');

  String get reConnectBtnText => Intl.message('Re-connect',
      name: 'reConnectBtnText', desc: 're-connect button text');

  String get noText => Intl.message('No', name: 'noText', desc: '"No" text');

  String get downloadingTipText => Intl.message(' downloading ',
      name: 'downloadingTipText', desc: '"downloading" tip text');

  String get completeTipText => Intl.message(' completed ',
      name: 'completeTipText', desc: '"complete" text');

  String get taskText =>
      Intl.message('task', name: 'taskText', desc: '"task" Text');

  String get deleteDialogTitle => Intl.message('Delete server config',
      name: 'deleteDialogTitle', desc: 'delete dialog title');

  String get deleteDialogContent =>
      Intl.message('Sure to delete current server config ?',
          name: 'deleteDialogContent', desc: 'delete dialog content');

  String get applyBtnText =>
      Intl.message('Apply', name: 'applyBtnText', desc: 'Apply button text');

  String get confirmBtnText => Intl.message('Confirm',
      name: 'confirmBtnText', desc: 'Confirm button text');

  String get cancelBtnText =>
      Intl.message('Cancel', name: 'cancelBtnText', desc: 'Cancel button text');

  String get connectedText => Intl.message('Connected to: ',
      name: 'connectedText', desc: 'connected text');
  String get aria2VersionLabel => Intl.message('Aria2 version: ',
      name: 'aria2VersionLabel', desc: 'Aria2 version label text');
  String get editText =>
      Intl.message('Edit', name: 'editText', desc: '"edit" Text');
  String get deleteText =>
      Intl.message('Delete', name: 'deleteText', desc: '"delete" Text');

  String get addNewServerConfig => Intl.message('Add new server config',
      name: 'addNewServerConfig', desc: 'Add new server config text');
  String get setting =>
      Intl.message('Setting', name: 'setting', desc: '"setting" Text');
  String get waiting =>
      Intl.message('Waiting', name: 'waiting', desc: '"waiting" Text');
  String get pausing =>
      Intl.message('Pausing', name: 'pausing', desc: '"pausing" Text');
  String get unparsing =>
      Intl.message('Unparsing', name: 'unparsing', desc: '"unparsing" Text');
  String get complete =>
      Intl.message('Complete', name: 'complete', desc: '"complete" Text');
  String get error =>
      Intl.message('Error', name: 'error', desc: '"error" Text');
  String get paused =>
      Intl.message('Paused', name: 'paused', desc: '"paused" Text');

  String get submit =>
      Intl.message('Submit', name: 'submit', desc: '"submit" Text');

  String get choose =>
      Intl.message('Choose ', name: 'choose', desc: '"choose" Text');

  String get reChoose =>
      Intl.message('Re-choose ', name: 'reChoose', desc: '"reChoose" Text');

  String get file => Intl.message(' file', name: 'file', desc: '"file" Text');

  String get more => Intl.message('More', name: 'more', desc: '"more" Text');

  String get address =>
      Intl.message(' address', name: 'address', desc: '"address" Text');

  String get taskTypeNameTorrent => Intl.message('Torrent',
      name: 'taskTypeNameTorrent', desc: 'task type name of torrent');
  String get taskTypeNameMagnet => Intl.message('Magnet',
      name: 'taskTypeNameMagnet', desc: 'task type name of magnet');
  String get taskTypeNameUrl => Intl.message('Url-downlod',
      name: 'taskTypeNameUrl', desc: 'task type name of url download');
  String get taskTypeNameMetalink => Intl.message('Metalink',
      name: 'taskTypeNameMetalink', desc: 'task type name of metalink');

  String get taskTypeDescTorrent =>
      Intl.message('Read torrent file to download...',
          name: 'taskTypeDescTorrent', desc: 'task type decription of torrent');
  String get taskTypeDescMagnet =>
      Intl.message('Input magnet link to dwnload...',
          name: 'taskTypeDescMagnet', desc: 'task type decription of magnet');
  String get taskTypeDescUrl =>
      Intl.message('Input http,ftp or some other protocol url to download...',
          name: 'taskTypeDescUrl',
          desc: 'task type decription of url download');
  String get taskTypeDescMetalink =>
      Intl.message('Read metalink file to download...',
          name: 'taskTypeDescMetalink',
          desc: 'task type decription of metalink');

  String get tipOfTorrent =>
      Intl.message('Supprt torren file format: ".torrent"',
          name: 'tipOfTorrent', desc: 'tip of torrent');
  String get tipOfMagnet =>
      Intl.message('Support Metalink file format:".metalink, .meta4"',
          name: 'tipOfMagnet', desc: 'tip of magnet');
  String get tipOfUrl =>
      Intl.message('Support protocol: HTTP/FTP/SFTP/BitTorrent',
          name: 'tipOfUrl', desc: 'tip of url download');
  String get tipOfMetalink => Intl.message('Magnet link start with "magnet:?"',
      name: 'tipOfMetalink', desc: 'tip of metalink');

  String get magnetText =>
      Intl.message('Magnet', name: 'magnetText', desc: 'magnet text');

  String get colorBlue =>
      Intl.message('Blue', name: 'colorBlue', desc: 'color blue');
  String get colorRed =>
      Intl.message('Red', name: 'colorRed', desc: 'color red');
  String get colorGreen =>
      Intl.message('Green', name: 'colorGreen', desc: 'color green');
  String get colorPurple =>
      Intl.message('Purple', name: 'colorPurple', desc: 'color purple');

  String get systemLanguage => Intl.message('Follow System',
      name: 'systemLanguage', desc: 'system language');

  String get authFailed => Intl.message('Aria2 authentication failed!',
      name: 'authFailed', desc: 'authentication failed tip');

  String get serverUnknownError =>
      Intl.message('Some aria2 unknown error occured!',
          name: 'serverUnknownError', desc: 'server unknown error tip');

  String get timeOutError => Intl.message('Connection timeout!',
      name: 'timeOutError', desc: 'timeOut error tip');

  String get serverRefusedError => Intl.message(
      'Connection refused by server! Please check the server config...',
      name: 'serverRefusedError',
      desc: 'server refused error tip');
  String get addText =>
      Intl.message('Add', name: 'addText', desc: '"Add" text');
  String get optionText =>
      Intl.message('Option', name: 'optionText', desc: '"Option" text');
  String get addSuccessTip => Intl.message('Success to add new Task!',
      name: 'addSuccessTip', desc: 'Add task success tip');

  String get checkOptionWarningTip =>
      Intl.message('Please check task option input!',
          name: 'checkOptionWarningTip', desc: 'Check option warning tip');
  String get checkSourceTip => Intl.message('Please check task source!',
      name: 'checkSourceTip', desc: 'check task source tip');
  String get linkInputDialogTitle => Intl.message('Please input link address',
      name: 'linkInputDialogTitle', desc: 'link input dialog title');
  String get linkInputLabel => Intl.message('Link address',
      name: 'linkInputLabel', desc: 'link input label');

  String get addAndDownload => Intl.message('Add & Download',
      name: 'addAndDownload', desc: 'add and download text');

  String get dirValidatorText_1 => Intl.message('Please input download path!',
      name: 'dirValidatorText_1', desc: 'dirValidatorText_1');

  String get dirValidatorText_2 =>
      Intl.message('Download result must under global path ',
          name: 'dirValidatorText_2', desc: 'dirValidatorText_2');

  String get downloadPath => Intl.message('Download path',
      name: 'downloadPath', desc: 'download path');

  String get speedLimit =>
      Intl.message('Speed limit', name: 'speedLimit', desc: 'speed limit');

  String get allowOverwrite => Intl.message('Allow overwrite download result',
      name: 'allowOverwrite', desc: 'allowOverwrite');

  String get language =>
      Intl.message('Language', name: 'language', desc: 'language');

  String get themeColor =>
      Intl.message('Theme', name: 'themeColor', desc: 'theme color');

  String get refreshDelay => Intl.message('Refresh',
      name: 'refreshDelay', desc: 'refresh delay');

  String get second => Intl.message('second', name: 'second', desc: 'second');

  String get changeGlobalOptionSuccessTip =>
      Intl.message('Success to change global option',
          name: 'changeGlobalOptionSuccessTip',
          desc: 'changeGlobalOptionSuccessTip');

  String get optionChangedTip =>
      Intl.message('Option changed,please click to commit.',
          name: 'optionChangedTip', desc: 'optionChangedTip');

  String get dirInputValidatorText =>
      Intl.message('Please input the download path!',
          name: 'dirInputValidatorText', desc: 'dirInputValidatorText');

  String get dirInputLabel => Intl.message('Default download path',
      name: 'dirInputLabel', desc: 'dirInputLabel');

  String get maxCurrentDownloadValidator_1 =>
      Intl.message('Please input the number!',
          name: 'maxCurrentDownloadValidator_1',
          desc: 'maxCurrentDownloadValidator_1');

  String get maxCurrentDownloadValidator_2 =>
      Intl.message('Number cannot start with 0!',
          name: 'maxCurrentDownloadValidator_2',
          desc: 'maxCurrentDownloadValidator_2');

  String get maxCurrentDownloadValidator_3 =>
      Intl.message('Please input legal number!',
          name: 'maxCurrentDownloadValidator_3',
          desc: 'maxCurrentDownloadValidator_3');

  String get maxCurrentDownloadValidator_4 =>
      Intl.message('Max current download must >1!',
          name: 'maxCurrentDownloadValidator_4',
          desc: 'maxCurrentDownloadValidator_4');

  String get maxCurrentDownload4 => Intl.message('Max current downloads',
      name: 'maxCurrentDownload4', desc: 'maxCurrentDownload4');

  String get ariaContinue => Intl.message('Continue the break',
      name: 'ariaContinue', desc: 'ariaContinue');

  String get checkIntegrity => Intl.message('Check integrity',
      name: 'checkIntegrity', desc: 'checkIntegrity');

  String get optimizeConcurrentDownloads =>
      Intl.message('Optimize current downloads',
          name: 'optimizeConcurrentDownloads',
          desc: 'optimizeConcurrentDownloads');

  String get confitExists => Intl.message('Config name exsits!',
      name: 'confitExists', desc: 'confitExists');

  String get addConfigSuccessTip =>
      Intl.message('Success to add server config!',
          name: 'addConfigSuccessTip', desc: 'addConfigSuccessTip');

  String get updateConfigSuccessTip =>
      Intl.message('Success to update server config!',
          name: 'updateConfigSuccessTip', desc: 'updateConfigSuccessTip');

  String get configName =>
      Intl.message('Name', name: 'configName', desc: 'configName');

  String get configNameValidatorText_1 =>
      Intl.message('Config name can not be empty!',
          name: 'configNameValidatorText_1', desc: 'configNameValidatorText_1');

  String get protocol =>
      Intl.message('Protocol', name: 'protocol', desc: 'protocol');

  String get host => Intl.message('HOST', name: 'host', desc: 'host');

  String get hostValidatorText_1 => Intl.message('Host can not be empty!',
      name: 'hostValidatorText_1', desc: 'hostValidatorText_1');

  String get port => Intl.message('PORT', name: 'port', desc: 'port');

  String get portValidatorText_1 => Intl.message('Port can not be empty!',
      name: 'portValidatorText_1', desc: 'portValidatorText_1');

  String get path => Intl.message('PATH', name: 'path', desc: 'path');

  String get secret => Intl.message('SECRET', name: 'secret', desc: 'secret');

  String get enableHttps =>
      Intl.message('Enable HTTPS', name: 'enableHttps', desc: 'enableHttps');

  String get appSetting =>
      Intl.message('App setting', name: 'appSetting', desc: 'appSetting');

  String get aria2Setting =>
      Intl.message('Aria2 setting', name: 'aria2Setting', desc: 'aria2Setting');

  String get aria2SettingWarning =>
      Intl.message('Please connect to Aria2 server before setting',
          name: 'aria2SettingWarning', desc: 'aria2SettingWarning');

  String get taskInfo =>
      Intl.message('Info', name: 'taskInfo', desc: 'taskInfo');

  String get fileList =>
      Intl.message('Files', name: 'fileList', desc: 'fileList');

  String get peers => Intl.message('Peers', name: 'peers', desc: 'peers');

  String get taskStatusOfDonloading => Intl.message('Downloading',
      name: 'taskStatusOfDonloading', desc: 'taskStatusOfDonloading');

  String get taskStatusOfComplete => Intl.message('Complete',
      name: 'taskStatusOfComplete', desc: 'taskStatusOfComplete');

  String get taskStatusOfError => Intl.message('Error',
      name: 'taskStatusOfError', desc: 'taskStatusOfError');

  String get taskStatusOfPaused => Intl.message('Paused',
      name: 'taskStatusOfPaused', desc: 'taskStatusOfPaused');

  String get taskStatusOfWaitting => Intl.message('Waitting',
      name: 'taskStatusOfWaitting', desc: 'taskStatusOfWaitting');

  String get taskName =>
      Intl.message('Task Name: ', name: 'taskName', desc: 'taskName');

  String get progress =>
      Intl.message('Progress: ', name: 'progress', desc: 'progress');

  String get status => Intl.message('Status: ', name: 'status', desc: 'status');

  String get bitFieldInfo =>
      Intl.message('BitField: ', name: 'bitFieldInfo', desc: 'bitFieldInfo');

  String get bitField =>
      Intl.message('bit fields ', name: 'bitField', desc: 'bitField');

  String get total => Intl.message('Total  ', name: 'total', desc: 'total');

  String get bit => Intl.message('bit  ', name: 'bit', desc: 'bit');
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
