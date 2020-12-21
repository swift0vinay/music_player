import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/services/MediaPlayer.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/screens/loader.dart';
import 'package:music_player/services/songModel.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ScanMusic extends StatefulWidget {
  MediaPlayer mediaPlayer;
  Function callBackToScan;
  Function callBackToRefresh;
  ScanMusic({this.mediaPlayer, this.callBackToRefresh, this.callBackToScan});
  @override
  _ScanMusicState createState() => _ScanMusicState();
}

class _ScanMusicState extends State<ScanMusic> {
  bool running = false;
  ProgressDialog pr;
  List<Song> songs;
  bool scan = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    pr.style(
        message: 'Scanning songs...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: Loader2(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Scan Music",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () async {
                await this.widget.mediaPlayer.stopSong();
                await musicBox.clear();
                this.widget.callBackToScan();
                await pr.show();
                // songs.clear();
                songs = await this.widget.mediaPlayer.getMusic();
                // this.widget.callBackToRefresh(songs);
                await pr.hide();
                setState(() {
                  scan = true;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: orange,
              child: Text(
                'Run Scan',
                style: TextStyle(color: white, fontSize: 20),
              ),
            ),
            scan
                ? Container(
                    child: Text(
                      'Total Songs : ${songs.length}',
                      style: TextStyle(color: white),
                    ),
                  )
                : Container()
          ],
        ),
      )),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:music_player/MediaPlayer.dart';

// import '../constants.dart';

// class ScanMusic extends StatefulWidget {
//   @override
//   _ScanMusicState createState() => _ScanMusicState();
// }

// class _ScanMusicState extends State<ScanMusic> {
//   Widget body;
//   Widget body2;
//   bool rs = false;
//   @override
//   void initState() {
//     super.initState();
//     body = Center(
//       child: RaisedButton(
//         onPressed: () async {
//           setState(() {
//             body = FutureBuilder(
//               future: MediaPlayer().getMusic(),
//               builder: (context, ss) {
//                 print('++++++++++++++++++++++++++++++++++++++++$ss');
//                 if (ss.connectionState == ConnectionState.done) {
//                   return Center(
//                     child: Text(
//                       "RECEIVERD",
//                       style: TextStyle(color: white),
//                     ),
//                   );
//                 } else {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               },
//             );
//             rs = true;
//           });
//         },
//         color: orange,
//         child: Text(
//           'Run Scan',
//           style: TextStyle(color: white, fontSize: 20),
//         ),
//       ),
//     );
//     // body2 = FutureBuilder(
//     //   future: !rs ? null : MediaPlayer().getMusic(),
//     //   builder: (context, ss) {
//     //     if (ss.hasData) {
//     //       return Center(
//     //         child: Text("RECEIVERD"),
//     //       );
//     //     } else {
//     //       return Center(
//     //         child: CircularProgressIndicator(),
//     //       );
//     //     }
//     //   },
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: black,
//       appBar: AppBar(
//         backgroundColor: black,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           color: white,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           "Scan Music",
//           style: TextStyle(color: white),
//         ),
//         centerTitle: true,
//       ),
//       body: body,
//     );
//   }
// }
