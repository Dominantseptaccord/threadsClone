import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  void addPost(String postContent, {String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      final emailUser = user.email!;
      final postRef = FirebaseFirestore.instance.collection("Posts").doc();
      final postId = postRef.id;

      final postData = {
        "postId": postId,
        "posts": postContent,
        'imageUrl': imageUrl,
        "email": emailUser,
        "time": Timestamp.now(),
        "likes": 0,
        "likedBy": [],
      };

      await postRef.set(postData);

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(emailUser)
          .set({
        "posts": FieldValue.arrayUnion([postData])
      }, SetOptions(merge: true));
    }
  }
  Future<void> toggleLikePost(String postId, String userEmail, bool isCurrentlyLiked) async {
    final postRef = FirebaseFirestore.instance.collection('Posts').doc(postId);

    if (isCurrentlyLiked) {
      await postRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userEmail]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userEmail]),
      });
    }
  }
}
