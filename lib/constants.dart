import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:music_player/screens/detailsPage.dart';
import 'package:music_player/services/songModel.dart';
import 'package:share/share.dart';

String boxName = 'music_player';
Box musicBox;
Color orange = Colors.red;
Color white = Colors.white;
Color black = Colors.black;
Color grey = Colors.grey;
Color mgrey = Colors.grey[850];
enum PlayerState { stopped, playing, paused }
enum PlayMode { repeat, loop, shuffle }
List<String> favs = new List();
// pr.style(
//   message: 'Downloading file...',
//   borderRadius: 10.0,
//   backgroundColor: Colors.white,
//   progressWidget: CircularProgressIndicator(),
//   elevation: 10.0,
//   insetAnimCurve: Curves.easeInOut,
//   progress: 0.0,
//   textDirection: TextDirection.rtl,
//   maxProgress: 100.0,
//   progressTextStyle: TextStyle(
//      color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//   messageTextStyle: TextStyle(
//      color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
//   );
myBottomSheet(BuildContext context, Song song) {
  print(song.artist);
  print(song.duration);
  print(song.artistId);
  int dur = song.duration;
  String min = (dur / 60).toStringAsFixed(0);
  double width = MediaQuery.of(context).size.width;

  return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) {
        return Container(
            height: 200,
            decoration: BoxDecoration(
                color: black.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0))),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () async {
                      await Share.shareFiles([song.data]);
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: width,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Text(
                            "Send Song",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ),
                        ))),
                InkWell(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              song: song,
                            ),
                          ));
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: width,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Text(
                            "Details",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ),
                        ))),
                SizedBox(
                  width: width * 0.8,
                  child: Divider(
                    height: 5.0,
                    color: white.withOpacity(0.3),
                    thickness: 0.5,
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: width,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ),
                        ))),
              ],
            ));
      });
}
