import 'package:flutter/material.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/songs/song.dart';
import '../../../../model/artist/comment.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../utils/async_value.dart';

class ArtistDetailsData {
  final List<Song> songs;
  final List<Comment> comments;
  ArtistDetailsData({required this.songs, required this.comments});
}

class ArtistDetailsViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final Artist artist;

  AsyncValue<ArtistDetailsData> data = AsyncValue.loading();
  bool isPosting = false;

  ArtistDetailsViewModel({
    required this.artistRepository,
    required this.artist,
  }) {
    fetchData();
  }

  Future<void> fetchData() async {
    data = AsyncValue.loading();
    notifyListeners();

    try {
      final songs = await artistRepository.fetchArtistSongs(artist.id);
      final comments = await artistRepository.fetchArtistComments(artist.id);
      data = AsyncValue.success(
        ArtistDetailsData(songs: songs, comments: comments),
      );
    } catch (e) {
      data = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;

    isPosting = true;
    notifyListeners();

    try {
      await artistRepository.postComment(artist.id, text);

      if (data.state == AsyncValueState.success && data.data != null) {
        final newComment = Comment(id: DateTime.now().toString(), text: text);
        final currentData = data.data!;
        final newComments = List<Comment>.from(currentData.comments)
          ..add(newComment);
        data = AsyncValue.success(
          ArtistDetailsData(songs: currentData.songs, comments: newComments),
        );
      } else {
        await fetchData();
      }
    } catch (e) {
    } finally {
      isPosting = false;
      notifyListeners();
    }
  }
}
