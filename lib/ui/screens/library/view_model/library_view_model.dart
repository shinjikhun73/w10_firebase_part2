import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';
import 'library_item_data.dart';

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final ArtistRepository artistRepository;

  final PlayerState playerState;

  AsyncValue<List<LibraryItemData>> data = AsyncValue.loading();

  LibraryViewModel({
    required this.songRepository,
    required this.playerState,
    required this.artistRepository,
  }) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    fetchSong();
  }

  Future<void> fetchSong({bool forceFetch = false}) async {
    // 1- Loading state
    if (!forceFetch) {
      data = AsyncValue.loading();
      notifyListeners();
    }

    try {
      // 1- Fetch songs
      List<Song> songs = await songRepository.fetchSongs(
        forceFetch: forceFetch,
      );

      // 2- Fetch artists
      List<Artist> artists = await artistRepository.fetchArtists(
        forceFetch: forceFetch,
      );

      // 3- Create the mapping artistid-> artist
      Map<String, Artist> mapArtist = {};
      for (Artist artist in artists) {
        mapArtist[artist.id] = artist;
      }

      List<LibraryItemData> data = songs
          .map(
            (song) =>
                LibraryItemData(song: song, artist: mapArtist[song.artistId]!),
          )
          .toList();

      this.data = AsyncValue.success(data);
    } catch (e) {
      // 3- Fetch is unsucessfull
      data = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> likeSong(LibraryItemData item) async {
    // make sure we have data
    if (data.state != AsyncValueState.success || data.data == null) return;

    final currentList = data.data!;
    final index = currentList.indexOf(item);
    if (index == -1) return;

    // save old item incase we revert
    final oldItem = currentList[index];

    // update like
    final newSong = item.song.copyWith(likes: item.song.likes + 1);
    final newItem = item.copyWith(song: newSong);

    currentList[index] = newItem;
    notifyListeners();

    // send request
    try {
      await songRepository.likeSong(newSong.id, newSong.likes);
    } catch (e) {
      //if error revert locally
      currentList[index] = oldItem;
      notifyListeners();
      throw Exception('updating like failed');
    }
  }

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();
}
