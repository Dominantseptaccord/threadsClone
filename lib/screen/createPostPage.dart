import 'package:flutter/material.dart';
import 'package:hatter/components/appBar.dart';
import 'package:hatter/database/post_service.dart';
class CreatePostPage extends StatelessWidget {
  final controllerPostController = TextEditingController();
  final post = PostService();
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWall(context),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
              children: [
                TextField(
                  controller: controllerPostController,
                  decoration: InputDecoration(
                      hintText: 'Write something...',
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.person)
                  ),
                ),
                SizedBox(height: 8,),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(Icons.photo)
                    ),
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(Icons.mic_rounded)
                    ),
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(Icons.location_on)
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    post.addPost(controllerPostController.text);
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
              ]),
        )
    );
  }
}