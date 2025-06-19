import 'dart:io';
import 'package:flutter/services.dart';

class AlarmPermissionHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.example.projectpember/alarm_permission',
  );

  static Future<bool> isExactAlarmAllowed() async {
    try {
      final bool result = await _channel.invokeMethod('isExactAlarmAllowed');
      return result;
    } catch (e) {
      return false;
    }
  }
}
