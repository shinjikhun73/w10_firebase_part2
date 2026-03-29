import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/async_value.dart';
import '../view_model/artist_details_view_model.dart';
import '../../library/widgets/library_item_tile.dart';
import '../../library/view_model/library_item_data.dart';
import '../../../widgets/comment/comment_tile.dart';

class ArtistDetailsContent extends StatefulWidget {
  const ArtistDetailsContent({super.key});

  @override
  State<ArtistDetailsContent> createState() => _ArtistDetailsContentState();
}

class _ArtistDetailsContentState extends State<ArtistDetailsContent> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment(ArtistDetailsViewModel mv) async {
    final text = _commentController.text;
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('comment is empty')));
      return;
    }
    await mv.addComment(text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ArtistDetailsViewModel mv = context.watch<ArtistDetailsViewModel>();
    final asyncValue = mv.data;

    Widget content;
    switch (asyncValue.state) {
      case AsyncValueState.loading:
        content = const Center(child: CircularProgressIndicator());
        break;
      case AsyncValueState.error:
        content = Center(
          child: Text(
            'error = ${asyncValue.error}',
            style: const TextStyle(color: Colors.red),
          ),
        );
        break;
      case AsyncValueState.success:
        final data = asyncValue.data!;

        final songsWidget = data.songs.isEmpty
            ? const Center(child: Text("No songs yet."))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.songs.length,
                itemBuilder: (context, index) {
                  return LibraryItemTile(
                    data: LibraryItemData(
                      song: data.songs[index],
                      artist: mv.artist,
                    ),
                    isPlaying: false,
                    onTap: () {},
                    onLike: () {},
                  );
                },
              );

        final commentsWidget = data.comments.isEmpty
            ? const Center(child: Text("No comments yet. Be the first!"))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.comments.length,
                itemBuilder: (context, index) {
                  return CommentTile(comment: data.comments[index]);
                },
              );

        content = SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Songs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              songsWidget,
              const SizedBox(height: 30),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              commentsWidget,
            ],
          ),
        );
        break;
    }

    return Column(
      children: [
        Expanded(child: content),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: mv.isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: mv.isPosting ? null : () => _submitComment(mv),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
