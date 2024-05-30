class Song {
  final int? songId;
  final String songTitle;
  final String albumImage;
  final String artist;
  final int? genre;
  final int? artistGender;
  final String songVidUrl;
  final String mrVidUrl;
  final int highestNote;
  final int lowestNote;
  final String karaokeNum;

  Song({
    required this.songId,
    required this.songTitle,
    required this.albumImage,
    required this.artist,
    required this.genre,
    required this.artistGender,
    required this.songVidUrl,
    required this.mrVidUrl,
    required this.highestNote,
    required this.lowestNote,
    required this.karaokeNum,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['song_id'],
      songTitle: json['song_title'],
      albumImage: json['album_image'],
      artist: json['artist'],
      genre: json['genre'],
      artistGender: json['artist_gender'],
      songVidUrl: json['song_vid_url'],
      mrVidUrl: json['mr_vid_url'],
      highestNote: json['highest_note'],
      lowestNote: json['lowest_note'],
      karaokeNum: json['karaoke_num'],
    );
  }
}
