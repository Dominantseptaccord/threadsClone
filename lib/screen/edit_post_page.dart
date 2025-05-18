import 'package:flutter/material.dart';
import 'package:hatter/models/post.dart';

class EditPostPage extends StatefulWidget {
  final Post post;
  const EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final newContent = _controller.text.trim();
    if (newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }
    Navigator.of(context).pop(newContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Edit your post...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
