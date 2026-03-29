import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../states/settings_state.dart';
import '../../../model/artist/artist.dart';
import '../../../data/repositories/artist/artist_repository.dart';
import 'view_model/artist_details_view_model.dart';
import 'widgets/artist_details_content.dart';

class ArtistDetailsScreen extends StatelessWidget {
  final Artist artist;

  const ArtistDetailsScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<AppSettingsState>();

    return ChangeNotifierProvider(
      create: (context) => ArtistDetailsViewModel(
        artistRepository: context.read<ArtistRepository>(),
        artist: artist,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(artist.name),
          backgroundColor: settingsState.theme.backgroundColor,
        ),
        body: const ArtistDetailsContent(),
      ),
    );
  }
}
