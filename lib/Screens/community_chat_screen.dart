import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petpal/Screens/chat_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUserId;
  String? _currentUserName;
  String _searchQuery = ''; // Store search query

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
        _currentUserName = user.displayName ?? 'Anonymous';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Action to add new contacts
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black),
                hintText: 'Search a Friend',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 241, 240, 239),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Update the search query
                });
              },
            ),
          ),

          SizedBox(height: 10),

          // Horizontal avatars at the top
          Container(
            height: 90,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: Colors.orange,));
                }

                final users = snapshot.data!.docs;

                if (users.isEmpty) {
                  return Center(child: Text('No users available'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemExtent: 70.0,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>?;

                    if (user == null) {
                      print('User data is null for document: ${users[index].id}');
                      return Container(); // Return empty container for invalid user
                    }

                    final userId = users[index].id;
                    final userName = user['name'] ?? 'Unknown User';
                    final userAvatar = user['profilePhotoUrl'] ??
                        'https://www.citypng.com/public/uploads/preview/download-profile-user-round-orange-icon-symbol-png-11639594360ksf6tlhukf.png';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              selectedUserId: userId,
                              selectedUserName: userName,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userAvatar),
                            radius: 30,
                          ),
                          SizedBox(height: 5),
                          Text(
                            userName,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SizedBox(height: 10),

          // List of chat contacts (showing last message and timestamp) with sliding delete functionality
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('userIds', arrayContains: _currentUserId) // Fetch chats where current user is involved
                  .orderBy('timestamp', descending: true) // Order by the latest message
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: Colors.orange,));
                }

                final chats = snapshot.data!.docs;

                if (chats.isEmpty) {
                  return Center(child: Text('No chats available'));
                }

                // Filter chats based on the search query
                final filteredChats = chats.where((chat) {
                  final chatData = chat.data() as Map<String, dynamic>?;
                  final userName = chatData?['receiverName'] ?? '';
                  return userName.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chatData = filteredChats[index].data() as Map<String, dynamic>?;

                    if (chatData == null) {
                      print('Chat data is null for document: ${filteredChats[index].id}');
                      return Container();
                    }

                    final userIds = chatData['userIds'] as List<dynamic>;
                    final otherUserId = userIds.firstWhere(
                      (id) => id != _currentUserId,
                      orElse: () => null,
                    );

                    // Attempt to fetch the other user's information
                    final lastMessage = chatData['lastMessage'] ?? '';
                    final timestamp = chatData['timestamp'] as Timestamp?;
                    final userAvatar = chatData['receiverProfilePhotoUrl'] ??
                        'https://www.citypng.com/public/uploads/preview/download-profile-user-round-orange-icon-symbol-png-11639594360ksf6tlhukf.png';
                    final userName = chatData['receiverName'] ?? 'Unknown User'; // Get the receiver name

                    // Fallback to the other user's ID if the name is not available
                    if (otherUserId != null) {
                      return Dismissible(
                        key: Key(filteredChats[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: AlignmentDirectional.centerEnd,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this chat?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Cancel the deletion
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Confirm the deletion
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await _firestore.collection('chats').doc(filteredChats[index].id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chat deleted')),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(userAvatar),
                          ),
                          title: Text(userName),
                          subtitle: Text(lastMessage),
                          trailing: Text(
                            timestamp != null ? _formatTimestamp(timestamp) : '',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            // Navigate to chat screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  selectedUserId: otherUserId,
                                  selectedUserName: userName, // Use the receiver name
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      print("Error: Couldn't find the other user in this chat.");
                      return Container(); // Handle error gracefully
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format timestamp (example formatting)
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute}";
  }
}
