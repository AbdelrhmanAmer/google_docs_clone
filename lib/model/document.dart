// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Document {
  final String uid;
  final String title;
  final List content;
  final DateTime createdAt;
  final String id;
  Document({
    required this.uid,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'id': id,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      uid: map['uid'] as String,
      title: map['title'] as String,
      content: List.from((map['content']) as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(map['createdAt'].toString()),
      ),
      id: map['_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Document.fromJson(String source) =>
      Document.fromMap(json.decode(source) as Map<String, dynamic>);
}
