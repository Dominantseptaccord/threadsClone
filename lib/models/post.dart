import 'package:cloud_firestore/cloud_firestore.dart';
class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String email;
  final String time;
  final int likes;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.email,
    required this.time,
    required this.likes,
    required this.likedBy,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      content: data['posts'] ?? '',
      imageUrl: data['imageUrl'],
      email: data['email'] ?? '',
      time: (data['time'] as Timestamp).toDate().toString(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

}