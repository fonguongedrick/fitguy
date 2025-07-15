import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  State<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  
  String _searchQuery = '';
  String _filterCategory = 'All';
  String _filterDifficulty = 'All';
  String _activeTab = 'workouts'; // 'workouts' or 'challenges'
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _activeTab = _tabController.index == 0 ? 'workouts' : 'challenges';
      });
    });
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
        title: const Text("Workout Management"),
        bottom: TabBar(
          controller: _tabController, // Provide the TabController here
          tabs: const [
            Tab(text: 'Workouts'),
            Tab(text: 'Challenges'),
          ],
          
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _activeTab == 'workouts' 
                ? _buildWorkoutsList()
                : _buildChallengesList(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    if (_activeTab == 'workouts') {
      _showWorkoutFormDialog();
    } else {
      _showChallengeFormDialog();
    }
  },
  child: const Icon(Icons.add),
),
    );
  }

  Widget _buildWorkoutsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('workouts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No workouts found"));
        }

        return _buildWorkoutItems(snapshot.data!.docs);
      },
    );
  }

  Widget _buildChallengesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('challenges').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No challenges found"));
        }

        return _buildChallengeItems(snapshot.data!.docs);
      },
    );
  }

  Widget _buildWorkoutItems(List<QueryDocumentSnapshot> docs) {
    final workouts = docs.map((doc) => {
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    }).toList();

    final filteredWorkouts = workouts.where((workout) {
      final title = (workout['title'] ?? '').toString().toLowerCase();
      final category = workout['category'] ?? 'HIIT';
      final difficulty = workout['difficulty'] ?? 'Beginner';
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      final matchesCategory = _filterCategory == 'All' || category == _filterCategory;
      final matchesDifficulty = _filterDifficulty == 'All' || difficulty == _filterDifficulty;
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();

    return ListView.builder(
      itemCount: filteredWorkouts.length,
      itemBuilder: (context, index) {
        final workout = filteredWorkouts[index];
        return _buildWorkoutCard(workout);
      },
    );
  }

  Widget _buildChallengeItems(List<QueryDocumentSnapshot> docs) {
    final challenges = docs.map((doc) => {
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    }).toList();

    final filteredChallenges = challenges.where((challenge) {
      final title = (challenge['title'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredChallenges.length,
      itemBuilder: (context, index) {
        final challenge = filteredChallenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ExpansionTile(
        title: Text(workout['title'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${workout['duration']} min • ${workout['calories']} cal'),
            Wrap(
              spacing: 8,
              children: [
                _buildWorkoutChip(workout['category']),
                _buildWorkoutChip(workout['difficulty'])
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showWorkoutFormDialog(workout: workout),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem('workouts', workout['id']),
            )
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workout['videoUrl'] != null)
                  _buildVideoPreview(workout['videoUrl']),
                Text(workout['description'] ?? '', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 10),
                const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<String>.from(workout['exercises'] ?? []).map((e) => Text('• $e')).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ExpansionTile(
        title: Text(challenge['title'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${challenge['duration']} days • ${challenge['points']} points'),
            if (challenge['workoutId'] != null)
              FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('workouts').doc(challenge['workoutId']).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final workout = snapshot.data!.data() as Map<String, dynamic>?;
                    return Text('Workout: ${workout?['title'] ?? 'N/A'}');
                  }
                  return const SizedBox();
                },
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showChallengeFormDialog(challenge: challenge),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem('challenges', challenge['id']),
            )
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (challenge['imageUrl'] != null)
                  Image.network(challenge['imageUrl'], height: 150, fit: BoxFit.cover),
                Text(challenge['description'] ?? '', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 10),
                const Text('Rewards:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<String>.from(challenge['rewards'] ?? []).map((e) => Text('• $e')).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoPreview(String videoUrl) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideoPlayer(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: snapshot.data!.value.aspectRatio,
            child: VideoPlayer(snapshot.data!),
          );
        } else {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoPlayer(String videoUrl) async {
    final controller = VideoPlayerController.network(videoUrl);
    await controller.initialize();
    return controller;
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search ${_activeTab == 'workouts' ? 'workouts' : 'challenges'}...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          if (_activeTab == 'workouts') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterCategory,
                    items: ['All', 'HIIT', 'Strength', 'Cardio', 'Yoga']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _filterCategory = val!),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterDifficulty,
                    items: ['All', 'Beginner', 'Intermediate', 'Advanced']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _filterDifficulty = val!),
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildWorkoutChip(String text) => Chip(
    label: Text(text), 
    backgroundColor: Colors.grey.shade200,
  );

  Future<void> _deleteItem(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${collection == 'workouts' ? 'Workout' : 'Challenge'} deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }

  void _showWorkoutFormDialog({Map<String, dynamic>? workout}) {
    final titleController = TextEditingController(text: workout?['title'] ?? '');
    final descController = TextEditingController(text: workout?['description'] ?? '');
    final durationController = TextEditingController(text: workout?['duration']?.toString() ?? '');
    final caloriesController = TextEditingController(text: workout?['calories']?.toString() ?? '');
    String category = workout?['category'] ?? 'HIIT';
    String difficulty = workout?['difficulty'] ?? 'Beginner';
    List<String> exercises = List<String>.from(workout?['exercises'] ?? []);
    final newExerciseController = TextEditingController();
    File? _videoFile;
    String? _videoUrl = workout?['videoUrl'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(workout == null ? 'Add Workout' : 'Edit Workout'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController, 
                    decoration: const InputDecoration(labelText: 'Title')
                  ),
                  TextField(
                    controller: descController, 
                    maxLines: 2, 
                    decoration: const InputDecoration(labelText: 'Description')
                  ),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: durationController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Duration (min)')
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: caloriesController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Calories')
                      ),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        items: ['HIIT', 'Strength', 'Cardio', 'Yoga']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => category = val!),
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: difficulty,
                        items: ['Beginner', 'Intermediate', 'Advanced']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => difficulty = val!),
                        decoration: const InputDecoration(labelText: 'Difficulty'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const Text("Workout Video", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_videoUrl != null && _videoFile == null)
                    if (_videoUrl != null) _buildVideoPreview(_videoUrl!),
                  if (_videoFile != null)
                    AspectRatio(
                      aspectRatio: 16/9,
                      child: VideoPlayer(VideoPlayerController.file(_videoFile!)
                        ..initialize().then((_) => setState(() {}))
                    )),
                  ElevatedButton(
                    onPressed: () async {
                      final video = await _picker.pickVideo(source: ImageSource.gallery);
                      if (video != null) {
                        setState(() {
                          _videoFile = File(video.path);
                          _videoUrl = null;
                        });
                      }
                    },
                    child: const Text("Select Video"),
                  ),
                  const SizedBox(height: 16),
                  const Text("Exercises", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...exercises.map((e) => ListTile(
                    title: Text(e),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => exercises.remove(e)),
                    ),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newExerciseController, 
                          decoration: const InputDecoration(labelText: 'Add Exercise')
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (newExerciseController.text.isNotEmpty) {
                            setState(() {
                              exercises.add(newExerciseController.text);
                              newExerciseController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Cancel")
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Upload video if new one was selected
                    String? videoUrl = _videoUrl;
                    if (_videoFile != null) {
                      final ref = _storage.ref().child('workout_videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
                      await ref.putFile(_videoFile!);
                      videoUrl = await ref.getDownloadURL();
                    }

                    final data = {
                      'title': titleController.text,
                      'description': descController.text,
                      'duration': int.tryParse(durationController.text) ?? 0,
                      'calories': int.tryParse(caloriesController.text) ?? 0,
                      'category': category,
                      'difficulty': difficulty,
                      'exercises': exercises,
                      if (videoUrl != null) 'videoUrl': videoUrl,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (workout == null) {
                      await _firestore.collection('workouts').add(data);
                    } else {
                      await _firestore.collection('workouts').doc(workout['id']).update(data);
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving workout: $e")),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showChallengeFormDialog({Map<String, dynamic>? challenge}) {
    final titleController = TextEditingController(text: challenge?['title'] ?? '');
    final descController = TextEditingController(text: challenge?['description'] ?? '');
    final durationController = TextEditingController(text: challenge?['duration']?.toString() ?? '');
    final pointsController = TextEditingController(text: challenge?['points']?.toString() ?? '');
    String? selectedWorkoutId = challenge?['workoutId'];
    List<String> rewards = List<String>.from(challenge?['rewards'] ?? []);
    final newRewardController = TextEditingController();
    File? _imageFile;
    String? _imageUrl = challenge?['imageUrl'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(challenge == null ? 'Add Challenge' : 'Edit Challenge'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController, 
                    decoration: const InputDecoration(labelText: 'Title')
                  ),
                  TextField(
                    controller: descController, 
                    maxLines: 3, 
                    decoration: const InputDecoration(labelText: 'Description')
                  ),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: durationController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Duration (days)')
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: pointsController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Points')
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('workouts').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final workouts = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedWorkoutId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('No workout')),
                          ...workouts.map((doc) => DropdownMenuItem(
                            value: doc.id,
                            child: Text(doc['title'] ?? 'Untitled Workout'),
                          )).toList(),
                        ],
                        onChanged: (val) => setState(() => selectedWorkoutId = val),
                        decoration: const InputDecoration(labelText: 'Linked Workout'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Challenge Image", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_imageUrl != null && _imageFile == null)
                    if (_imageUrl != null) Image.network(_imageUrl!, height: 150, fit: BoxFit.cover),
                  if (_imageFile != null)
                    Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                  ElevatedButton(
                    onPressed: () async {
                      final image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _imageFile = File(image.path);
                          _imageUrl = null;
                        });
                      }
                    },
                    child: const Text("Select Image"),
                  ),
                  const SizedBox(height: 16),
                  const Text("Rewards", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...rewards.map((e) => ListTile(
                    title: Text(e),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => rewards.remove(e)),
                    ),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newRewardController, 
                          decoration: const InputDecoration(labelText: 'Add Reward')
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (newRewardController.text.isNotEmpty) {
                            setState(() {
                              rewards.add(newRewardController.text);
                              newRewardController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Cancel")
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Upload image if new one was selected
                    String? imageUrl = _imageUrl;
                    if (_imageFile != null) {
                      final ref = _storage.ref().child('challenge_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
                      await ref.putFile(_imageFile!);
                      imageUrl = await ref.getDownloadURL();
                    }

                    final data = {
                      'title': titleController.text,
                      'description': descController.text,
                      'duration': int.tryParse(durationController.text) ?? 7,
                      'points': int.tryParse(pointsController.text) ?? 100,
                      if (selectedWorkoutId != null) 'workoutId': selectedWorkoutId,
                      'rewards': rewards,
                      if (imageUrl != null) 'imageUrl': imageUrl,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (challenge == null) {
                      await _firestore.collection('challenges').add(data);
                    } else {
                      await _firestore.collection('challenges').doc(challenge['id']).update(data);
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving challenge: $e")),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        }
      ),
    );
  }
}