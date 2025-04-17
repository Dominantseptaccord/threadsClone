import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
class PostService {
  void addPost(String postContent) {
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null && user.email!=null) {
      final emailUser = user.email!;
      FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({
        "posts": FieldValue.arrayUnion([{
          "posts": postContent,
          "time": Timestamp.now(),
        }]),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection("Posts")
          .doc("Posts")
          .set({
          emailUser: FieldValue.arrayUnion([{
          "posts": postContent,
          "time": Timestamp.now(),
        }]),
      }, SetOptions(merge: true));
    }
  }
}