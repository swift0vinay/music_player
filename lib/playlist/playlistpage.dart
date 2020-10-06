import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/playlist/showFavs.dart';
import 'package:music_player/services/songModel.dart';

class Playlist extends StatefulWidget {
  List<Song> songs;
  Song playingSong;
  Playlist({this.songs, this.playingSong});
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.favorite_border,
              color: orange,
            ),
            title: Text(
              "Favourites",
              style: TextStyle(color: white),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowFav(
                            songs: this.widget.songs,
                            playingSong: this.widget.playingSong,
                          )));
            },
          ),
        ],
      ),
    );
  }
}
