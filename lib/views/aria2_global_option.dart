import 'package:flutter/material.dart';

class Aria2GlobalOptionsWidgets extends StatefulWidget {
  const Aria2GlobalOptionsWidgets({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Aria2GlobalOptionsStates();
}

class _Aria2GlobalOptionsStates extends State<Aria2GlobalOptionsWidgets>
    with AutomaticKeepAliveClientMixin<Aria2GlobalOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(
      child: Text('Aria2全局设置'),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
