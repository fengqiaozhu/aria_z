import 'package:flutter/material.dart';

/// level = 1:成功，2：失败，3：警告
void showCustomSnackBar(BuildContext context, int level, Widget content) {
  Color bg = Colors.grey;

  switch (level) {
    case 1:
      bg = Colors.green;
      break;
    case 2:
      bg = Colors.red;
      break;
    case 3:
      bg = Colors.orange;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      backgroundColor: bg,
    ),
  );
}
