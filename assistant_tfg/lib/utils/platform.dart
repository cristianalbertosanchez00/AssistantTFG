import 'package:flutter/material.dart';

class PlatformUtils {
  static bool isMobilePlatform(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;
  }
}
