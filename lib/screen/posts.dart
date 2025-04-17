import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/appBar.dart';
import 'profile_page.dart';
import 'package:hatter/database/post_service.dart';
import 'package:hatter/components/navbotbar.dart';
import 'package:hatter/screen/post_details.dart';
import 'package:hatter/components/post_card.dart';
class Post extends StatefulWidget{
  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final controllerPostController = TextEditingController();
  final post = PostService();

  Future<List<Map<String, dynamic>?>> fetchPosts() async {
    final docPostSnapshot = await FirebaseFirestore.instance.collection('Posts')
        .doc('Posts')
        .get();
    if (docPostSnapshot.exists) {
      Map<String, dynamic>? data = docPostSnapshot.data();
      if (data != null) {
        List<Map<String, dynamic>> allPosts = [];

        data.forEach((email, postList) {
          if (postList is List) {
            for (var post in postList) {
              final postMap = Map<String, dynamic>.from(post);
              postMap['email'] = email;
              allPosts.add(postMap);
            }
          }
        }
        );
        return allPosts;
      }
    }
    return [];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(),
      appBar: AppBarWall(context),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
            children: [
              const SizedBox(height: 35.0,),
              TextField(
                controller: controllerPostController,
                decoration: InputDecoration(
                    hintText: 'Write something...',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.person)
                ),
              ),
              Expanded(
                  child: FutureBuilder(
                  future: fetchPosts(),
                  builder: (context,snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Post do not have'),);
                    }
                    final posts = snapshot.data!;
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final content = post?['posts'] ?? '';
                          final email = post?['email'] ?? '';
                          final timestamp = post?['time'] as Timestamp?;
                          final time = timestamp?.toDate();

                          return PostCard(content: content, email: email, time: time.toString());
                        },
                      );
                  }
                  ),
              ),
              GestureDetector(
                onTap: () async {
                  post.addPost(controllerPostController.text);
                  setState(() {});
                  controllerPostController.clear();
                },
                child: Container(
                  padding: EdgeInsets.all(25.0),
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Center(
                    child: Text(
                      'Push',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]
        ),
      ),);
  }
}