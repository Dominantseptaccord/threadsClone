import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'editProfile.dart';
import 'settings_page.dart';
import '../models/post.dart';
import 'package:hatter/components/post_card_profile.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _pickAndUploadImage() async {
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
        .doc(currentUser.email)
        .snapshots();

    final postsCountStream = FirebaseFirestore.instance
        .collection('Posts')
        .where('email', isEqualTo: currentUser.email)
        .snapshots()
        .map((snap) => snap.size);

    final userPostsStream = FirebaseFirestore.instance
        .collection('Posts')
        .where('email', isEqualTo: currentUser.email)
        .snapshots();


    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDocStream,
        builder: (ctx, userSnap) {
          if (userSnap.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || !userSnap.data!.exists) {
            return const Center(child: Text('No profile data'));
          }

          final data = userSnap.data!.data()!;
          final username = data['username'] as String? ?? '';
          final email = currentUser.email!;
          final bio = data['bio'] as String? ?? '';
          final imageUrl = data['profileImage'] as String? ?? '';
          final followers = (data['followers'] as List<dynamic>?)?.length ?? 0;
          final following = (data['following'] as List<dynamic>?)?.length ?? 0;

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
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
                                : const AssetImage('assets/profile_default.jpg')
                            as ImageProvider,
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
                          Positioned(
                            left: 0,
                            bottom: -4,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(username,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController(text: bio);
                              return AlertDialog(
                                title: const Text('Edit Bio'),
                                content: TextField(
                                  controller: ctrl,
                                  maxLines: 3,
                                  decoration:
                                  const InputDecoration(border: OutlineInputBorder()),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(ctrl.text),
                                      child: const Text('Save')),
                                ],
                              );
                            },
                          );
                          if (result != null) {
                            await _saveBio(result.trim());
                          }
                        },
                        child: Text(
                          bio.isEmpty ? 'Tap to add bio' : bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: bio.isEmpty
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<int>(
                        stream: postsCountStream,
                        builder: (ctx, postsSnap) {
                          final postsCount = postsSnap.hasData ? postsSnap.data! : 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(count: postsCount, label: 'Posts'),
                              _StatItem(count: followers, label: 'Followers'),
                              _StatItem(count: following, label: 'Following'),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const EditProfilePage()));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SettingsPage(
                                  onLocaleChange: (locale) {
                                    // Здесь ваш код обработки смены локали
                                    // Например, вызвать setState или обновить глобальное состояние
                                    print('Locale changed to $locale');
                                  },
                                  currentLocale: Localizations.localeOf(context),
                                ),
                              ));

                            },
                            icon: const Icon(Icons.settings_rounded),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Posts",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ➕ Все посты пользователя
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: userPostsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!.docs;

                    if (posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text("You haven't posted anything yet.")),
                      );
                    }

                    return Column(
                      children: posts
                          .map((doc) => PostCard(
                        post: Post.fromFirestore(doc),
                      ))
                          .toList(),
                    );
                  },
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
        Text('$count',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}
