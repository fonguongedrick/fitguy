import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String name;

  const UserProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fitness Enthusiast',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileStat('120', 'Workouts'),
                const SizedBox(width: 24),
                _buildProfileStat('5.2K', 'Followers'),
                const SizedBox(width: 24),
                _buildProfileStat('320', 'Following'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Now following')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUserPosts(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserPosts() {
    return Column(
      children: [
        _buildPostCard(
          'New personal best! Deadlift 180kg',
          '2h ago',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
          '45',
          '12',
        ),
        const SizedBox(height: 16),
        _buildPostCard(
          'Morning workout routine',
          '1d ago',
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c',
          '32',
          '8',
        ),
      ],
    );
  }

  Widget _buildPostCard(
      String content, String time, String image, String likes, String comments) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage:
                      NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(content),
              ],
            ),
          ),
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                const SizedBox(width: 4),
                Text(likes),
                const SizedBox(width: 16),
                const Icon(Icons.comment, color: Colors.grey, size: 20),
                const SizedBox(width: 4),
                Text(comments),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
