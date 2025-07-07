import 'package:fitguy1/features/home/presentation/page/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/like_button.dart';
import 'community_detailed_screen.dart';


class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _showCommentField = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected image: ${pickedFile.path}')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStoriesRow(),
              const SizedBox(height: 24),
              _buildCommunityPosts(context),
              if (_showCommentField) _buildCommentInputField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 4),
    );
  }

  Widget _buildStoriesRow() {
    final stories = [
      {'name': 'You', 'icon': Icons.add_circle, 'isYou': true},
      {'name': 'Alex', 'icon': Icons.person, 'isActive': true},
      {'name': 'Jamie', 'icon': Icons.person, 'isActive': true},
      {'name': 'Taylor', 'icon': Icons.person, 'isActive': false},
      {'name': 'Morgan', 'icon': Icons.person, 'isActive': true},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return GestureDetector(
            onTap: () {
              if (story['isYou'] as bool) {
                _pickImageFromGallery();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing ${story['name']}\'s story')),
                );
              }
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (story['isActive'] as bool? ?? false)
                            ? Colors.deepPurple
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: (story['isYou'] as bool? ?? false)
                          ? Container(
                        color: Colors.deepPurple.withOpacity(0.1),
                        child: const Icon(Icons.add,
                            size: 30, color: Colors.deepPurple),
                      )
                          : Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.person,
                            size: 30, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story['name'] as String,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityPosts(BuildContext context) {
    final posts = [
      {
        'user': 'Alex',
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        'time': '2h ago',
        'content': 'Just hit a new PR on bench press! 150kg 🎉',
        'likes': '40',
        'comments': '5',
        'isCommunity': false,
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
      },
      {
        'user': 'Fitness Club',
        'avatar': 'https://randomuser.me/api/portraits/lego/1.jpg',
        'time': '5h ago',
        'content': 'Join our weekend cycling challenge! 50km through the city.',
        'likes': '23',
        'comments': '12',
        'isCommunity': true,
        'image': 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c',
      },
      {
        'user': 'Morgan',
        'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
        'time': '1d ago',
        'content': '30 day yoga challenge progress. Day 15 and feeling amazing!',
        'likes': '100',
        'comments': '23',
        'isCommunity': false,
        'image': 'https://images.unsplash.com/photo-1545389336-cf090694435e',
      },
    ];

    return Column(
      children: posts.map((post) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                if (post['isCommunity'] as bool) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityDetailScreen(
                        name: post['user'] as String,
                        activity: post['content'] as String,
                        members: '1.2K',
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        name: post['user'] as String,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(post['avatar'] as String),
                      ),
                      title: Text(
                        post['user'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(post['time'] as String),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        post['content'] as String,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (post['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post['image'] as String,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          LikeButton(likes: int.parse(post['likes'] as String)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              setState(() {
                                _showCommentField = !_showCommentField;
                                if (_showCommentField) {
                                  _commentFocusNode.requestFocus();
                                }
                              });
                            },
                          ),
                          Text(post['comments'] as String),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Comment: ${_commentController.text}')),
                );
                _commentController.clear();
                setState(() {
                  _showCommentField = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 10,
      items: [
        _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
        _buildNavItem(Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Meals'),
        _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Progress'),
        _buildNavItem(Icons.people_outline, Icons.people, 'Community'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/workouts');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/meal-plans');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/progress');
        }
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}