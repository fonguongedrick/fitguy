import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String name;
  final String activity;
  final String members;

  const CommunityDetailScreen({
    super.key,
    required this.name,
    required this.activity,
    required this.members,
  });

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
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.people,
                  size: 60,
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
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
            Text(
              '$members members',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                activity,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Joined community')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Join Community',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCommunityActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityActivities() {
    return Column(
      children: [
        _buildActivityCard(
          'Alex',
          'Just completed the 30-day challenge!',
          '2h ago',
          'https://randomuser.me/api/portraits/men/1.jpg',
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Jamie',
          'Shared a new workout routine',
          '5h ago',
          'https://randomuser.me/api/portraits/women/1.jpg',
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Taylor',
          'Posted new nutrition tips',
          '1d ago',
          'https://randomuser.me/api/portraits/men/2.jpg',
        ),
      ],
    );
  }

  Widget _buildActivityCard(
      String user, String content, String time, String avatar) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
