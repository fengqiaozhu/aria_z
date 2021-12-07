// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:aria_z/utils/tools.dart';
import 'package:flutter/material.dart';

class SpeedShower extends StatelessWidget {
  final int? downloadSpeed;

  final int? uploadSpeed;

  const SpeedShower(
      {Key? key, required this.downloadSpeed, required this.uploadSpeed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
      downloadSpeed == null
          ? const WidgetSpan(child: SizedBox())
          : TextSpan(
              children: [
                  const WidgetSpan(
                      child: Icon(
                    Icons.file_download_outlined,
                    size: 18,
                    color: Colors.green,
                  )),
                  TextSpan(text: formatSpeed(downloadSpeed ?? 0)),
                ],
              style: const TextStyle(
                fontFamily: 'Coda',
                fontSize: 14,
              )),
      downloadSpeed == null || uploadSpeed == null
          ? const WidgetSpan(child: SizedBox())
          : const WidgetSpan(
              child: SizedBox(
              height: 16,
              child: VerticalDivider(
                indent: 1,
                endIndent: 5,
                color: Colors.grey,
                thickness: 2,
                width: 20,
              ),
            )),
      uploadSpeed == null
          ? const WidgetSpan(child: SizedBox())
          : TextSpan(
              children: [
                  const WidgetSpan(
                      child: Icon(
                    Icons.file_upload_outlined,
                    size: 18,
                    color: Colors.red,
                  )),
                  TextSpan(text: formatSpeed(uploadSpeed ?? 0)),
                ],
              style: const TextStyle(
                fontFamily: 'Coda',
                fontSize: 14,
              ))
    ]));
  }
}
