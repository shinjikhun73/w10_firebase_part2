import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import '../../../model/artist/comment.dart';
import '../../dtos/comment_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = Uri.https(
    'week-8-practice-a099b-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  List<Artist>? _cachedArtists;

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    // return cachhe if available
    if (!forceFetch && _cachedArtists != null) {
      return _cachedArtists!;
    }
    final http.Response response = await http.get(artistsUri);
    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);
      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }

      // store in memory
      _cachedArtists = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    final http.Response response = await http.get(
      Uri.https(
        'week-8-practice-a099b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/songs.json',
      ),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> songJson = json.decode(response.body);
      List<Song> result = [];
      for (final entry in songJson.entries) {
        final songId = entry.key;
        final data = entry.value;
        if (data is Map &&
            data['title'] != null &&
            data['artistId'] == artistId) {
          result.add(SongDto.fromJson(songId, data as Map<String, dynamic>));
        }
      }
      return result;
    }
    throw Exception('Failed to load artist songs');
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    final http.Response response = await http.get(
      Uri.https(
        'week-8-practice-a099b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/comments/$artistId.json',
      ),
    );
    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> commentJson = json.decode(response.body);
      List<Comment> result = [];
      for (final entry in commentJson.entries) {
        result.add(
          CommentDto.fromJson(entry.key, entry.value as Map<dynamic, dynamic>),
        );
      }
      return result;
    }
    return [];
  }

  @override
  Future<void> postComment(String artistId, String text) async {
    await http.post(
      Uri.https(
        'week-8-practice-a099b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/comments/$artistId.json',
      ),
      body: json.encode(CommentDto.toJson(text)),
    );
  }
}
