import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatter/models/post.dart';
import 'package:hatter/components/post_card.dart';
import 'package:hatter/database/post_service.dart';
import 'package:hatter/components/navbotbar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  Set<String> selectedCategories = {'recent'};

  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _showSearchField = true;
      });
    });
  }

  Future<void> fetchPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .get();

    final posts = snapshot.docs.map((doc) {
      final data = doc.data();
      return Post(
        id     : doc.id,
        content: data['posts']  as String? ?? '',
        email  : data['email']  as String? ?? '',
        time   : (data['time'] as Timestamp?)?.toDate().toString() ?? '',
        likes  : data['likes']  as int?    ?? 0,
        likedBy: List<String>.from(data['likedBy'] ?? []),
      );
    }).toList();

    setState(() {
      allPosts      = posts;
      filteredPosts = posts;
    });
  }

  void _filterAndSortPosts() {
    final query = _searchController.text.toLowerCase();

    List<Post> result = allPosts.where((post) {
      return post.content.toLowerCase().contains(query);
    }).toList();

    if (selectedCategories.contains('recent') && selectedCategories.contains('popular')) {
      result.sort((a, b) => b.time.compareTo(a.time));
      result = result.take(50).toList();
      result.sort((a, b) => b.likes.compareTo(a.likes));
    } else if (selectedCategories.contains('recent')) {
      result.sort((a, b) => b.time.compareTo(a.time));
    } else if (selectedCategories.contains('popular')) {
      result.sort((a, b) => b.likes.compareTo(a.likes));
    }

    setState(() {
      filteredPosts = result;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
    _filterAndSortPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Posts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: AnimatedOpacity(
              opacity: _showSearchField ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: TextField(
                controller: _searchController,
                onChanged: (text) => _filterAndSortPosts(),
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: Text('Recent'),
                  selected: selectedCategories.contains('recent'),
                  onSelected: (_) => _toggleCategory('recent'),
                  selectedColor: Colors.blue.shade200,
                ),
                SizedBox(width: 10),
                FilterChip(
                  label: Text('Popular'),
                  selected: selectedCategories.contains('popular'),
                  onSelected: (_) => _toggleCategory('popular'),
                  selectedColor: Colors.blue.shade200,
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              key: ValueKey(selectedCategories.join(',')),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  key: ValueKey(filteredPosts[index].id),
                  post: filteredPosts[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
