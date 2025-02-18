import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petpal/Screens/community_chat_screen.dart';
import 'package:petpal/Screens/create_post_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  @override
  _CommunityFeedScreenState createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String postContent = "";

  Future<String?> uploadImage(XFile image) async {
    try {
      final userId = _auth.currentUser?.uid;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('posts/$userId/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> createPost() async {
    if (postContent.isEmpty) return;
    final user = _auth.currentUser;

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await uploadImage(_imageFile!);
    }

    await _firestore.collection('posts').add({
      'content': postContent,
      'userId': user?.uid,
      'images': imageUrl != null ? [imageUrl] : [],
      'likes': 0,
      'comments': [],
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      postContent = "";
      _imageFile = null;
    });
  }

  void pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Community Feed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSelectionScreen()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180.0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.orange,
                      ));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No posts yet.'));
                    }

                    final posts = snapshot.data!.docs;

                    if (index >= posts.length) {
                      return SizedBox
                          .shrink(); // Empty widget if index out of range
                    }

                    final post = posts[index];

                    // Fetch post uploader's name
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(post['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.orange));
                        }

                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return Center(child: Text('User data unavailable'));
                        }

                        final userName = userSnapshot.data!['name'] ?? 'User';

                        return _buildPostItem(context, post, userName);
                      },
                    );
                  },
                );
              },
              childCount: 1000, // Adjust based on your needs
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(
      BuildContext context, DocumentSnapshot post, String userName) {
    final postId = post.id;
    final content = post['content'] ?? 'No content available';
    final images = List<String>.from(post['images'] ?? []);
    final likes = post['likes'] ?? 0;
    final comments = List<String>.from(post['comments'] ?? []);

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(post['userId']).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.orange,
          ));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: Text('User data unavailable'));
        }

        final userData = userSnapshot.data!;
        final userProfilePicture = '';

        return PostCard(
          postId: postId,
          content: content,
          images: images,
          likes: likes,
          comments: comments,
          userName: userName,
          userProfilePicture:
              userProfilePicture, // Pass profile picture to PostCard
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 231, 231, 231),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How do you\ncreate your post?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostScreen()),
                    );
                  },
                  child: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://th.bing.com/th/id/R.86bebc8ceb313545207c639be56f0651?rik=JOO9Wnj8b0GWTA&riu=http%3a%2f%2fpngimg.com%2fuploads%2fdog%2fdog_PNG50380.png&ehk=othL9M41KKnxNrXWUSnkAmjsQ%2fiWbfeqyhCdWFCEDIQ%3d&risl=1&pid=ImgRaw&r=0',
              width: 100,
              height: 160,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String content;
  final List<String> images;
  final int likes;
  final List<String> comments;
  final String userName;
  final String userProfilePicture;

  PostCard({
    required this.postId,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.userName,
    required this.userProfilePicture,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  void checkIfLiked() async {
    final userId = _auth.currentUser?.uid;
    final likesDoc = await _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(userId)
        .get();

    if (mounted) {
      setState(() {
        isLiked = likesDoc.exists;
      });
    }
  }

  void toggleLike() async {
    final userId = _auth.currentUser?.uid;
    final postRef = _firestore.collection('posts').doc(widget.postId);

    if (isLiked) {
      await postRef.collection('likes').doc(userId).delete();
      postRef.update({'likes': FieldValue.increment(-1)});
    } else {
      await postRef.collection('likes').doc(userId).set({});
      postRef.update({'likes': FieldValue.increment(1)});
    }

    setState(() {
      isLiked = !isLiked;
    });
  }

  void addComment(String commentText) async {
    final userId = _auth.currentUser?.uid;
    final comment = {
      'userId': userId,
      'comment': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0), // Slightly larger padding
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        color: Colors.white, // Subtle background color
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        child: Padding(
          // Add padding inside the card
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24.0, // Slightly larger avatar
                  backgroundImage: widget.userProfilePicture.isNotEmpty
                      ? NetworkImage(widget.userProfilePicture)
                      : NetworkImage(
                              'https://www.citypng.com/public/uploads/preview/download-profile-user-round-orange-icon-symbol-png-11639594360ksf6tlhukf.png')
                          as ImageProvider,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    // Text(
                    //   'Golden Retriever • Fayetteville',
                    //   style: TextStyle(fontSize: 14.0, color: Colors.grey),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Text(widget.content, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 8.0),
              if (widget.images.isNotEmpty)
                GridView.count(
                  shrinkWrap: true, // Prevents expanding
                  crossAxisCount: 1, // Display in 1 column
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  children: widget.images
                      .map((imageUrl) => ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8.0), // Rounded image borders
                          child: Image.network(imageUrl, fit: BoxFit.cover)))
                      .toList(),
                ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Replace the existing IconButton for likes with FutureBuilder
                  FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('likes')
                        .doc(_auth.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(color: Colors.orange);
                      }

                      if (!snapshot.hasData) {
                        return Text('Error loading likes');
                      }

                      final isLiked = snapshot.data!.exists;

                      return IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Colors.orange : Colors.grey,
                        ),
                        onPressed:
                            toggleLike, // Your toggle function remains unchanged
                      );
                    },
                  ),
                  Text('${widget.likes} Likes',
                      style: TextStyle(
                          color: isLiked ? Colors.orange : Colors.black54)),
                  SizedBox(width: 16.0),
                  IconButton(
                    icon: Icon(Icons.comment, color: Colors.grey),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CommentSection(postId: widget.postId);
                          });
                    },
                  ),
                  Text('${widget.comments.length} Comments',
                      style: TextStyle(color: Colors.black54)),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.grey),
                    onPressed: () {
                      // Handle share press
                    },
                  ),
                  Text('Share', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String postId;

  CommentSection({required this.postId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void postComment() async {
    if (_commentController.text.isEmpty) return;

    await _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': _commentController.text,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No comments yet.'));
              }

              final comments = snapshot.data!.docs;

              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment['text'] ?? 'No text'),
                    subtitle: FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(comment['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        }
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return Text('User not found');
                        }
                        final userName = userSnapshot.data!['name'] ?? 'User';
                        return Text('User: $userName');
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(hintText: 'Enter your comment'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
