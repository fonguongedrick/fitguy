import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterRole = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users_fitguy').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final docs = snapshot.data!.docs;
                final users = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {'id': doc.id, ...data};
                }).toList();

                final filteredUsers = users.where((user) {
                  final name = (user['fullName'] ?? '').toString().toLowerCase();
                  final email = (user['email'] ?? '').toString().toLowerCase();
                  final role = (user['role'] ?? 'user').toString();
                  final status = (user['status'] ?? 'Active').toString();

                  final matchesSearch = name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
                  final matchesStatus = _filterStatus == 'All' || status == _filterStatus;
                  final matchesRole = _filterRole == 'All' || role == _filterRole;

                  return matchesSearch && matchesStatus && matchesRole;
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final imageUrl = user['photoUrl'] ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['fullName'] ?? 'user')}&background=0D8ABC&color=fff';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(imageUrl),
                          onBackgroundImageError: (_, __) => const Icon(Icons.person),
                        ),
                        title: Text(user['fullName'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? 'No Email'),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user['role'] ?? 'user') == 'Admin' ? Colors.red : Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (user['role'] ?? 'user').toString().toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user['status'] ?? 'Active') == 'Active' ? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (user['status'] ?? 'Active').toString().toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleAction(value, user),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'view_details', child: Text('View Details')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete User')),
                            if ((user['role'] ?? 'user') == 'user')
                              const PopupMenuItem(value: 'make_admin', child: Text('Make Admin')),
                            if ((user['role'] ?? 'user') == 'Admin')
                              const PopupMenuItem(value: 'remove_admin', child: Text('Remove Admin')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  items: ['All', 'Active', 'Inactive']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _filterStatus = val!),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterRole,
                  items: ['All', 'Admin', 'User']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _filterRole = val!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _handleAction(String action, Map<String, dynamic> user) async {
    final userId = user['id'];
    switch (action) {
      case 'make_admin':
        await _firestore.collection('users_fitguy').doc(userId).update({'role': 'Admin'});
        _toast('User promoted to Admin');
        break;
      case 'remove_admin':
        await _firestore.collection('users_fitguy').doc(userId).update({'role': 'User'});
        _toast('Admin demoted to User');
        break;
      case 'delete':
        await _showDeleteConfirmation(userId);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'view_details':
        _showUserDetailsDialog(user);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestore.collection('users_fitguy').doc(userId).delete();
      _toast('User deleted');
    }
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['fullName']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    final ageController = TextEditingController(text: user['age']?.toString() ?? '');
    final heightController = TextEditingController(text: user['height']?.toString() ?? '');
    final weightController = TextEditingController(text: user['weight']?.toString() ?? '');
    
    String role = user['role'] ?? 'user';
    String status = user['status'] ?? 'Active';
    String gender = user['gender'] ?? 'Male';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ['Male', 'Female'].contains(gender) ? gender : 'Male',
                        items: ['Male', 'Female']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => gender = val!,
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        decoration: const InputDecoration(labelText: 'Height (cm)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        decoration: const InputDecoration(labelText: 'Weight (kg)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: ['User', 'Admin'].contains(role) ? role : 'User',
                  items: ['User', 'Admin']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => role = val!,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: ['Active', 'Inactive'].contains(status) ? status : 'Active',
                  items: ['Active', 'Inactive']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => status = val!,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updateData = {
                'fullName': nameController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
                'role': role,
                'status': status,
                'gender': gender,
              };

              if (ageController.text.isNotEmpty) {
                updateData['age'] = (int.tryParse(ageController.text) ?? 0).toString();
              }
              if (heightController.text.isNotEmpty) {
                updateData['height'] = (double.tryParse(heightController.text) ?? 0.0).toString();
              }
              if (weightController.text.isNotEmpty) {
                updateData['weight'] = (double.tryParse(weightController.text) ?? 0.0).toString();
              }

              await _firestore.collection('users_fitguy').doc(user['id']).update(updateData);
              Navigator.pop(context);
              _toast('User updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }
}

class UserDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['fullName'] ?? 'User Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Workouts', icon: Icon(Icons.fitness_center)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
            Tab(text: 'Activity', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildWorkoutsTab(),
          _buildProgressTab(),
          _buildActivityTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final user = widget.user;
    final imageUrl = user['photoUrl'] ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['fullName'] ?? 'user')}&background=0D8ABC&color=fff';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildInfoRow('Full Name', user['fullName'] ?? 'Not provided'),
                  _buildInfoRow('Email', user['email'] ?? 'Not provided'),
                  _buildInfoRow('Phone', user['phone'] ?? 'Not provided'),
                  _buildInfoRow('Age', user['age']?.toString() ?? 'Not provided'),
                  _buildInfoRow('Gender', user['gender'] ?? 'Not provided'),
                  _buildInfoRow('Height', user['height'] != null ? '${user['height']} cm' : 'Not provided'),
                  _buildInfoRow('Weight', user['weight'] != null ? '${user['weight']} kg' : 'Not provided'),
                  _buildInfoRow('Role', user['role'] ?? 'user'),
                  _buildInfoRow('Status', user['status'] ?? 'Active'),
                  _buildInfoRow('Joined', user['createdAt'] != null 
                      ? DateFormat('MMM dd, yyyy').format((user['createdAt'] as Timestamp).toDate())
                      : 'Not available'),
                ],
              ),
            ),
          ),
          if (user['fitnessGoals'] != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fitness Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(user['fitnessGoals'].toString()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('workouts')
          
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No workouts found'));
        }

        final workouts = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index].data() as Map<String, dynamic>;
            final date = workout['createdAt'] != null
                ? DateFormat('MMM dd, yyyy').format((workout['createdAt'] as Timestamp).toDate())
                : 'Unknown date';

            return Card(
              child: ExpansionTile(
                title: Text(workout['workoutName'] ?? 'Unnamed Workout'),
                subtitle: Text('$date • ${workout['duration'] ?? 'Unknown'} minutes'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (workout['exercises'] != null) ...[
                          const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...((workout['exercises'] as List).map((exercise) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• ${exercise['name']} - ${exercise['sets']} sets, ${exercise['reps']} reps'),
                            )
                          ).toList()),
                        ],
                        if (workout['notes'] != null) ...[
                          const SizedBox(height: 8),
                          const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(workout['notes'].toString()),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('progress')
          .where('userId', isEqualTo: widget.user['id'])
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No progress data found'));
        }

        final progressData = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: progressData.length,
          itemBuilder: (context, index) {
            final progress = progressData[index].data() as Map<String, dynamic>;
            final date = progress['date'] != null
                ? DateFormat('MMM dd, yyyy').format((progress['date'] as Timestamp).toDate())
                : 'Unknown date';

            return Card(
              child: ListTile(
                title: Text('Progress Update'),
                subtitle: Text(date),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (progress['weight'] != null)
                      Text('${progress['weight']} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (progress['bodyFat'] != null)
                      Text('${progress['bodyFat']}% BF'),
                  ],
                ),
                onTap: () => _showProgressDetails(progress),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('user_activity')
          .where('userId', isEqualTo: widget.user['id'])
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No activity found'));
        }

        final activities = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index].data() as Map<String, dynamic>;
            final timestamp = activity['timestamp'] != null
                ? DateFormat('MMM dd, yyyy HH:mm').format((activity['timestamp'] as Timestamp).toDate())
                : 'Unknown time';

            return Card(
              child: ListTile(
                leading: Icon(_getActivityIcon(activity['type'])),
                title: Text(activity['action'] ?? 'Unknown action'),
                subtitle: Text(timestamp),
                trailing: activity['details'] != null 
                    ? IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showActivityDetails(activity),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'workout':
        return Icons.fitness_center;
      case 'login':
        return Icons.login;
      case 'profile':
        return Icons.person;
      case 'progress':
        return Icons.trending_up;
      default:
        return Icons.event;
    }
  }

  void _showProgressDetails(Map<String, dynamic> progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progress Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (progress['weight'] != null)
              Text('Weight: ${progress['weight']} kg'),
            if (progress['bodyFat'] != null)
              Text('Body Fat: ${progress['bodyFat']}%'),
            if (progress['muscle'] != null)
              Text('Muscle Mass: ${progress['muscle']} kg'),
            if (progress['notes'] != null)
              Text('Notes: ${progress['notes']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Details'),
        content: Text(activity['details'].toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}