class Song {
  int id;
  String title;
  String artist;
  int artistId;
  String data;
  int duration;
  String album;
  int albumId;
  String displayName;
  int size;
  String albumArt;
  int trackId;
  Song(
      {this.trackId,
      this.albumId,
      this.title,
      this.albumArt,
      this.duration,
      this.artist,
      this.album,
      this.displayName,
      this.size,
      this.artistId,
      this.id,
      this.data});
  Song.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    artist = map["artist"];
    artistId = map["artistId"];
    title = map["title"];
    displayName = map["displayName"];
    size = map["size"];
    album = map["album"];
    albumId = map["albumId"];
    duration = map["duration"];
    data = map["data"];
    albumArt = map["albumArt"];
    trackId = map["trackId"];
  }
}
