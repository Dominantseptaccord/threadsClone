import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'editProfile.dart';

class UserProfilePage extends StatefulWidget {
  final String userEmail;
  const UserProfilePage({super.key, required this.userEmail});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late final bool isSelf;
  bool isFollowing = false;
  bool loadingFollow = false;

  @override
  void initState() {
    super.initState();
    isSelf = widget.userEmail == currentUser.email;
  }

  Future<void> _toggleFollow(bool follow) async {
    setState(() => loadingFollow = true);
    final meRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
    final themRef = FirebaseFirestore.instance.collection('Users').doc(widget.userEmail);

    final batch = FirebaseFirestore.instance.batch();
    if (follow) {
      batch.update(meRef, {
        'following': FieldValue.arrayUnion([widget.userEmail])
      });
      batch.update(themRef, {
        'followers': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      batch.update(meRef, {
        'following': FieldValue.arrayRemove([widget.userEmail])
      });
      batch.update(themRef, {
        'followers': FieldValue.arrayRemove([currentUser.email])
      });
    }
    await batch.commit();
    setState(() {
      isFollowing = follow;
      loadingFollow = false;
    });
  }

  Future<void> _saveBio(String newBio) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .set({'bio': newBio}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final userDocStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userEmail)
        .snapshots();

    final postsCountStream = FirebaseFirestore.instance
        .collection('Posts')
        .where('email', isEqualTo: widget.userEmail)
        .snapshots()
        .map((s) => s.size);

    return Scaffold(
      appBar: AppBar(title: Text(isSelf ? 'My Profile' : 'Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDocStream,
        builder: (ctx, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('User not found'));
          }
          final data = snap.data!.data()!;
          final username = data['username'] as String? ?? widget.userEmail.split('@').first;
          final bio = data['bio'] as String? ?? '';
          final imageUrl = data['profileImage'] as String? ?? '';
          final followers = (data['followers'] as List?)?.length ?? 0;
          final following = (data['following'] as List?)?.length ?? 0;

          // Если чужой профиль, определяем статус follow
          if (!isSelf) {
            isFollowing = (data['followers'] as List?)?.contains(currentUser.email) ?? false;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const AssetImage('assets/profile_default.jpg') as ImageProvider,
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                          if (isSelf)
                            Positioned(
                              left: 0,
                              bottom: -4,
                              child: GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(source: ImageSource.gallery);
                                  if (picked == null) return;
                                  final file = File(picked.path);
                                  final ref = FirebaseStorage.instance
                                      .ref()
                                      .child('profile_images/profile_${currentUser.uid}.jpg');
                                  await ref.putFile(file);
                                  final url = await ref.getDownloadURL();
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(currentUser.email)
                                      .set({'profileImage': url}, SetOptions(merge: true));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.black54),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.userEmail, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: isSelf
                            ? () async {
                          final res = await showDialog<String>(
                            context: context,
                            builder: (c) {
                              final ctrl = TextEditingController(text: bio);
                              return AlertDialog(
                                title: const Text('Edit Bio'),
                                content: TextField(
                                  controller: ctrl,
                                  maxLines: 3,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(c).pop(),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () => Navigator.of(c).pop(ctrl.text),
                                      child: const Text('Save')),
                                ],
                              );
                            },
                          );
                          if (res != null) {
                            await _saveBio(res.trim());
                          }
                        }
                            : null,
                        child: Text(
                          bio.isEmpty ? (isSelf ? 'Tap to add bio' : '') : bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: bio.isEmpty ? Colors.grey : Colors.black87),
                        ),
                      ),

                      const SizedBox(height: 24),

                      StreamBuilder<int>(
                        stream: postsCountStream,
                        builder: (ctx, psnap) {
                          final pc = psnap.data ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(count: pc, label: 'Posts'),
                              _StatItem(count: followers, label: 'Followers'),
                              _StatItem(count: following, label: 'Following'),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      if (isSelf)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
                          },
                          child: const Text('Edit Profile'),
                        )
                      else
                        ElevatedButton(
                          onPressed: loadingFollow ? null : () => _toggleFollow(!isFollowing),
                          child: Text(loadingFollow ? '...' : (isFollowing ? 'Unfollow' : 'Follow')),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  const _StatItem({required this.count, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}
