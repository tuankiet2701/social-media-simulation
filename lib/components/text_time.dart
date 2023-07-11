import 'dart:async';

import 'package:flutter/material.dart';

class TextTime extends StatefulWidget {
  final Widget? child;
  const TextTime({super.key, this.child});

  @override
  State<TextTime> createState() => _TextTimeState();
}

class _TextTimeState extends State<TextTime> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
