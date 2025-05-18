import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hatter/models/post.dart';
import 'package:lottie/lottie.dart';

class PostDetail extends StatefulWidget {
  final Post post;

  const PostDetail({super.key, required this.post});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> futureComments;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    futureComments = fetchComments();
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    final doc = await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['comments'] is List) {
        return List<Map<String, dynamic>>.from(data['comments']);
      }
    }
    return [];
  }

  Future<void> addCommentToPost(String commentContent) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Получаем данные пользователя
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .get();

    final userData = userDoc.data();
    final username = userData?['username'] ?? currentUser.email!.split('@').first;
    final profileImage = userData?['profileImage'] ?? '';

    final commentData = {
      "email": currentUser.email,
      "username": username,
      "profileImage": profileImage,
      "comment": commentContent,
      "time": DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
    };

    final postRef =
    FirebaseFirestore.instance.collection('Posts').doc(widget.post.id);

    await postRef.set({
      "comments": FieldValue.arrayUnion([commentData])
    }, SetOptions(merge: true));
  }


  void _sendComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);

    await addCommentToPost(text);
    commentController.clear();
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isSending = false;
      futureComments = fetchComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWall(context),
      resizeToAvoidBottomInset: false, // не обрезаем body при появлении клавы
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.post.email)
                    .get(),
                builder: (context, snap) {
                  String username = widget.post.email.split('@').first;
                  String profileUrl = '';
                  if (snap.hasData && snap.data!.exists) {
                    final data = snap.data!.data()!;
                    username = (data['username'] as String?) ?? username;
                    profileUrl = (data['profileImage'] as String?) ?? '';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple.shade300,
                          backgroundImage:
                          profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                          child: profileUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm')
                                    .format(DateTime.parse(widget.post.time)),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),

              if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        loadingBuilder: (ctx, child, prog) {
                          if (prog == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: prog.expectedTotalBytes != null
                                  ? prog.cumulativeBytesLoaded /
                                  (prog.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: futureComments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final c = comments[i];
                      final e = (c['email'] as String?) ?? 'anonymous';
                      final name = (c['username'] as String?) ?? (e.contains('@') ? e.split('@').first : e);
                      final profileImage = (c['profileImage'] as String?) ?? '';
                      final text = (c['comment'] as String?) ?? '';
                      final time = (c['time'] as String?) ?? '';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.deepPurple.shade200,
                            backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                            child: profileImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(text),
                                  const SizedBox(height: 6),
                                  Text(time,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                  decoration: InputDecoration(
                    hintText: 'Write something...',
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.comment),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isSending
                  ? SizedBox(
                width: 40,
                height: 40,
                child: Lottie.asset('assets/loading.json'),
              )
                  : CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepPurple,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendComment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
