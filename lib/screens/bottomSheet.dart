import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/screens/detailsPage.dart';
import 'package:music_player/services/songModel.dart';
import 'package:share/share.dart';

myBottomSheet(BuildContext context, Song song) {
  print(song.artist);
  print(song.duration);
  print(song.artistId);
  int dur = song.duration;
  String min = (dur / 60).toStringAsFixed(0);
  double width = MediaQuery.of(context).size.width;
  TextStyle labelStyle = TextStyle(
    fontSize: 15.0,
    color: white,
    letterSpacing: 1,
  );
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
                            style: labelStyle,
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
                            style: labelStyle,
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
                            style: labelStyle,
                          ),
                        ))),
              ],
            ));
      });
}
