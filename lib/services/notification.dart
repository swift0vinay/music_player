import 'package:flutter/services.dart';

class MyNotification {
  static const methodChannel = MethodChannel('notification');
  static Map<String, Function> _listeners = new Map();
  static Future<dynamic> _utilsHandler(MethodCall methodCall) async {
    _listeners.forEach((event, callBack) {
      if (methodCall.method == event) {
        callBack();
      }
    });
  }

  static Future showNotification(
      String artist, String title, String musicPath, bool isPlaying) async {
    try {
      final Map<String, dynamic> map = <String, dynamic>{
        'title': title,
        'artist': artist,
        'isPlaying': isPlaying,
        'imagePath': musicPath,
      };
      print('here $map');
      await methodChannel.invokeMethod('showNotification', map).then((value) {
        print('doneeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
        methodChannel.setMethodCallHandler(_utilsHandler);
      }).catchError((e) {
        print('errroro ${e.toString()}');
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  static Future hideNotification() async {
    try {
      await methodChannel.invokeMethod('hideNotification');
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  static setListeners(String event, Function callBack) {
    _listeners.addAll({event: callBack});
  }
}
