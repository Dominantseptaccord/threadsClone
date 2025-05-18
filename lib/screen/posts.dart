import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatter/screen/createPostPage.dart';
import '../components/appBar.dart';
import 'package:hatter/database/post_service.dart';
import 'package:hatter/components/post_card.dart';
import 'package:hatter/models/post.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class PostScreen extends StatefulWidget {
  @override
  State<PostScreen> createState() => _PostState();
}

class _PostState extends State<PostScreen> {
  bool _isFocused = false;
  TextEditingController _searchController = TextEditingController();
  final controllerPostController = TextEditingController();
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  final postService = PostService();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final postSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .get();

    if (postSnapshot.docs.isNotEmpty) {
      List<Post> posts = [];

      for (var doc in postSnapshot.docs) {
        final data = doc.data();
        posts.add(
          Post(
            id: doc.id,
            content: data['content'] ?? '',
            imageUrl: data['imageUrl'],
            email: data['email'] ?? '',
            time: (data['time'] as Timestamp?)?.toDate().toString() ?? '',
            likes: data['likes'] ?? 0,
            likedBy: List<String>.from(data['likedBy'] ?? []),
          ),
        );
      }

      setState(() {
        allPosts = posts;
        filteredPosts = posts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWall(context),
      body: Column(
        children: [
          const SizedBox(height: 35.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            // Old Container (DELETE IT)
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(_isFocused ? 16 : 8),
              decoration: BoxDecoration(
                color: _isFocused ? Colors.grey[200] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: _isFocused ? 8 : 4,
                  )
                ],
              ),
              child: Column(
                children: [
                  Focus(
                    onFocusChange: (focused) =>
                        setState(() => _isFocused = focused),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (ctx, anim, secAnim) => CreatePostPage(),
                          transitionDuration: const Duration(milliseconds: 400),
                          transitionsBuilder: (ctx, anim, secAnim, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: Curves.easeOut));
                            return SlideTransition(
                              position: anim.drive(tween),
                              child: child,
                            );
                          },
                        ));
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: controllerPostController,
                          decoration: const InputDecoration(
                            hintText: 'Write something...',
                            border: InputBorder.none,
                            icon: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: null,
                        icon: const Icon(Icons.photo),
                      ),
                      IconButton(
                        onPressed: null,
                        icon: const Icon(Icons.mic_rounded),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      'assets/loading.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts found'));
                }

                final docs = snapshot.data!.docs;
                final posts =
                docs.map((doc) => Post.fromFirestore(doc)).toList();

                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        delay: const Duration(milliseconds: 100),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: PostCard(post: posts[index]),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
