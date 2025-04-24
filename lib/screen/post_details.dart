import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/appBar.dart';
import '../components/navbotbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostDetail extends StatefulWidget {
  final String content;
  final String email;
  final String time;

  PostDetail({super.key, required this.content, required this.email, required this.time});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> futureComments;

  @override
  void initState() {
    super.initState();
    futureComments = fetchComments();
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    final docPostSnapshot = await FirebaseFirestore.instance.collection('Posts').doc('Posts').get();

    if (docPostSnapshot.exists) {
      Map<String, dynamic>? data = docPostSnapshot.data();
      if (data != null) {
        List<Map<String, dynamic>> allComments = [];

        data.forEach((email, postList) {
          if (postList is List) {
            for (var post in postList) {
              if (post['posts'] == widget.content) {
                if (post['comments'] != null && post['comments'] is List) {
                  for (var comment in post['comments']) {
                    allComments.add(Map<String, dynamic>.from(comment));
                  }
                }
              }
            }
          }
        });

        return allComments;
      }
    }
    return [];
  }

  Future<void> addCommentToPost(String email, String postContent, String commentContent) async {
    final doc = FirebaseFirestore.instance.collection('Posts').doc('Posts');
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data[email] != null) {
        List posts = data[email];
        for (var post in posts) {
          if (post['posts'] == postContent) {
            if (post['comments'] == null) {
              post['comments'] = [];
            }
            post['comments'].add({
              "email": FirebaseAuth.instance.currentUser?.email,
              "comment": commentContent,
              "time": DateFormat('dd.MM.yyyy').format(Timestamp.now().toDate()),
            });
            await doc.set(data, SetOptions(merge: true));
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(),
      appBar: AppBarWall(context),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.email),
                        const SizedBox(height: 25),
                        Text(widget.content),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Comments do not have'));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment["comment"] ?? ''),
                      subtitle: Text(comment["email"] ?? ''),
                      trailing: Text(
                        comment["time"] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Write something...',
                border: const OutlineInputBorder(),
                icon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;

                    await addCommentToPost(widget.email, widget.content, commentController.text.trim());
                    commentController.clear();
                    setState(() {
                      futureComments = fetchComments(); // Обновим комментарии
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
