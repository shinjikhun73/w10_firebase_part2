import '../../model/artist/comment.dart';

class CommentDto {
  static const String textKey = 'text';

  static Comment fromJson(String id, Map<dynamic, dynamic> json) {
    return Comment(id: id, text: json[textKey] ?? '');
  }

  static Map<String, dynamic> toJson(String text) {
    return {textKey: text};
  }
}
