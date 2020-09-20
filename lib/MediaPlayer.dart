import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:music_player/songModel.dart';

import 'constants.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

class MediaPlayer {
  static const myChannel = MethodChannel('com.example.mc/tester');
  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  VoidCallback startHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;
  MediaPlayer() {
    myChannel.setMethodCallHandler(platformCallHandler);
  }

  Future<List<Song>> getMusic() async {
    try {
      await Future.delayed(Duration(milliseconds: 1)).then((value) {
        scanStart.value = true;
      });
      List<Song> songs = new List();
      final Map<String, dynamic> rs =
          Map.from(await myChannel.invokeMethod('getMusic'));
      rs.forEach((key, value) {
        Song song = new Song.fromMap(Map.from(value));
        songs.add(song);
      });
      return songs;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  String ans = "Wait";
  Future<int> playMusic(String path) async {
    try {
      final int rs = await myChannel
          .invokeMethod('playMusic', <String, dynamic>{'path': path});
      return rs;
    } on PlatformException catch (e) {
      print(e);
      return -1;
    }
  }

  Future<dynamic> resumeSong() async {
    try {
      final int rs = await myChannel.invokeMethod('resumeMusic');
      return rs;
    } on PlatformException catch (e) {
      print(e);
      return -1;
    }
  }

  Future<dynamic> stopSong() async {
    try {
      final int rs = await myChannel.invokeMethod('stopMusic');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<dynamic> seekSong(double seconds) async {
    try {
      final int rs = await myChannel
          .invokeMethod('seekMusic', <String, dynamic>{'position': seconds});
      return rs;
    } on PlatformException catch (e) {
      print(e);
      return -1;
    }
  }

  Future<dynamic> pauseSong() async {
    try {
      final int rs = await myChannel.invokeMethod('pauseMusic');
      return rs;
    } on PlatformException catch (e) {
      print(e);
      return -1;
    }
  }

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
  }

  void setStartHandler(VoidCallback callback) {
    startHandler = callback;
  }

  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  Future platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onScanStart":
        {
          print(call.arguments);
          // scanStart.value = call.arguments;
          print('00000000000000000000000000000000000${scanStart.value}');
          break;
        }
      case "onScanComplete":
        {
          print(call.arguments);
          scanStart.value = call.arguments;
          print('00000000000000000000000000000000000${scanStart.value}');

          break;
        }
      case "audio.onDuration":
        {
          final duration = Duration(milliseconds: call.arguments);
          if (durationHandler != null) {
            durationHandler(duration);
          }
          break;
        }
      case "audio.onCurrentPosition":
        {
          if (positionHandler != null) {
            positionHandler(new Duration(milliseconds: call.arguments));
          }
          break;
        }
      case "audio.onStart":
        {
          if (startHandler != null) {
            startHandler();
          }
          break;
        }
      case "audio.onComplete":
        {
          bool rs = call.arguments;
          print('sogn rs is $rs');

          if (completionHandler != null) {
            print('song completed');
            if (rs) {
              completionHandler();
            }
          }
          break;
        }
      case "audio.onError":
        if (errorHandler != null) {
          errorHandler(call.arguments);
        }
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }
}
