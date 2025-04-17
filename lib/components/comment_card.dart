import 'package:flutter/material.dart';
import 'package:hatter/screen/post_details.dart';

class PostCard extends StatelessWidget {
  final String content;
  final String email;
  final String time;

  PostCard(
      {super.key, required this.content, required this.email, required this.time});

  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(),
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      const SizedBox(height: 25,),
                      Text(content),
                    ],
                  ),
                ),
              ],
            )
        ),
      );
  }
}