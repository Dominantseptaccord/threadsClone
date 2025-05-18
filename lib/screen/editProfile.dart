import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _ctrlUsername = TextEditingController();
  final _ctrlBio = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();
    final data = snap.data()!;
    _ctrlUsername.text = data['username'] as String? ?? '';
    _ctrlBio.text = data['bio'] as String? ?? '';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .set({
      'username': _ctrlUsername.text.trim(),
      'bio': _ctrlBio.text.trim(),
    }, SetOptions(merge: true));
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrlUsername,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrlBio,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
