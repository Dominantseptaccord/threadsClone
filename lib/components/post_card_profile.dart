import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hatter/database/post_service.dart';
import 'package:hatter/models/post.dart';
import 'package:hatter/screen/post_details.dart';
import 'package:hatter/screen/user_profile_page.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  final PostService postService = PostService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();

    final email = currentUser?.email ?? '';
    isLiked = widget.post.likedBy.contains(email);
    likeCount = widget.post.likes;

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.email)
        .get();
  }

  void _onLikePressed() async {
    final userEmail = currentUser?.email;
    if (userEmail == null) return;

    final nowLiked = !isLiked;
    setState(() {
      isLiked = nowLiked;
      likeCount += nowLiked ? 1 : -1;
    });

    await _likeController.forward();
    await _likeController.reverse();

    await postService.toggleLikePost(
      widget.post.id,
      userEmail,
      !nowLiked,
    );
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('Posts').doc(widget.post.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    }
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: widget.post.content);

    final newContent = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter new content',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null && newContent.isNotEmpty && newContent != widget.post.content) {
      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({'posts': newContent});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUser?.email == widget.post.email;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getUserData(),
      builder: (context, snap) {
        final Widget titleWidget;
        final hasProfileImg = snap.hasData &&
            snap.data!.data()!.containsKey('profileImage') &&
            (snap.data!.data()!['profileImage'] as String).isNotEmpty;

        if (snap.connectionState == ConnectionState.waiting) {
          titleWidget = const Text(
            '-',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          );
        } else if (snap.hasError || !snap.hasData || !snap.data!.exists) {
          final fallback = widget.post.email.split('@').first;
          titleWidget = Text(
            fallback,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          );
        } else {
          final data = snap.data!.data()!;
          final username =
              (data['username'] as String?) ?? widget.post.email.split('@').first;
          titleWidget = Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          );
        }

        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    PostDetail(post: widget.post),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 20,
                        child: hasProfileImg
                            ? ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/profile_default.jpg',
                            image: snap.data!.data()!['profileImage'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                          ),
                        )
                            : const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  UserProfilePage(userEmail: widget.post.email),
                            ));
                          },
                          child: titleWidget,
                        ),
                      ),
                      Text(
                        widget.post.time.split('.')[0],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isOwner)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editPost();
                            } else if (value == 'delete') {
                              _deletePost();
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('Edit'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),

                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: Icon(Icons.broken_image)),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ScaleTransition(
                        scale: _likeScale,
                        child: IconButton(
                          iconSize: 28,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isLiked ? Colors.red : Colors.grey[600],
                          onPressed: _onLikePressed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
