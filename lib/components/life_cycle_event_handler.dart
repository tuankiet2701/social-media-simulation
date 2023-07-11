import 'package:flutter/material.dart';

class LifeCycleEventHandler extends WidgetsBindingObserver {
  final Function resumeCallBack;
  final Function detachedCallBack;
  LifeCycleEventHandler({
    required this.resumeCallBack,
    required this.detachedCallBack,
  });

  @override
  Future<void> didChangeAppLifeCycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }
}
