import '../../../model/artist/artist.dart';

import '../../../model/songs/song.dart';
import '../../../model/artist/comment.dart';

abstract class ArtistRepository {
  Future<List<Artist>> fetchArtists({bool forceFetch = false});

  Future<Artist?> fetchArtistById(String id);

  Future<List<Song>> fetchArtistSongs(String artistId);
  Future<List<Comment>> fetchArtistComments(String artistId);
  Future<void> postComment(String artistId, String text);
}
