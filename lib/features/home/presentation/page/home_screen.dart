import 'package:fitguy1/features/home/presentation/page/meal_plan_screen.dart';
import 'package:fitguy1/features/home/presentation/page/work_out_details_screen.dart';
import 'package:fitguy1/features/home/presentation/page/work_out_screen.dart';
import 'package:fitguy1/features/profile/presentation/profile_prage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Popular',
    'Lower Body',
    'Upper Body',
    'Cardio',
    'Yoga'
  ];
  
  String? userName;
  String greeting = 'Good Morning';
  bool isConnected = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Data from Firebase
  List<Map<String, dynamic>> _quickExercises = [];
  List<Map<String, dynamic>> _recommendedPlans = [];
  Map<String, dynamic>? _todaysChallenge;
  bool _isLoading = true;
  String? _errorMessage;

  // Video controllers
  late List<VideoPlayerController> _exerciseControllers;

  @override
  void initState() {
    super.initState();
    _initializeGreeting();
    _loadUserData();
    _checkConnectivity();
    _fetchAllData();
  }

  @override
  void dispose() {
    for (var controller in _exerciseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      await Future.wait([
        _fetchQuickExercises(),
        _fetchRecommendedPlans(),
        _fetchTodaysChallenge(),
      ]);
      _initializeVideoControllers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data. Please try again later.';
      });
      // Try to load cached data
      await _loadCachedData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedExercises = prefs.getString('cachedExercises');
    final cachedPlans = prefs.getString('cachedPlans');
    final cachedChallenge = prefs.getString('cachedChallenge');

    if (cachedExercises != null) {
      setState(() {
        _quickExercises = List<Map<String, dynamic>>.from(json.decode(cachedExercises));
      });
    }
    if (cachedPlans != null) {
      setState(() {
        _recommendedPlans = List<Map<String, dynamic>>.from(json.decode(cachedPlans));
      });
    }
    if (cachedChallenge != null) {
      setState(() {
        _todaysChallenge = Map<String, dynamic>.from(json.decode(cachedChallenge));
      });
    }
  }

  Future<void> _cacheData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedExercises', json.encode(_quickExercises));
    await prefs.setString('cachedPlans', json.encode(_recommendedPlans));
    if (_todaysChallenge != null) {
      await prefs.setString('cachedChallenge', json.encode(_todaysChallenge));
    }
  }

  Future<void> _fetchQuickExercises() async {
    try {
      final snapshot = await _firestore.collection('workouts')
        .where('category', isEqualTo: 'HIIT')
        .limit(2)
        .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _quickExercises = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'title': data['title'] ?? 'No Title',
              'videoUrl': data['videoUrl'] ?? '',
              'duration': '${data['duration'] ?? 0} min',
              'level': data['difficulty'] ?? 'Beginner',
              'description': data['description'] ?? 'No description',
              'calories': data['calories'] ?? 0,
            };
          }).toList();
        });
        await _cacheData();
      }
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  Future<void> _fetchRecommendedPlans() async {
    try {
      final snapshot = await _firestore.collection('meals')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _recommendedPlans = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'title': data['name'] ?? 'No Title',
              'imageUrl': data['imageUrl'],
              'subtitle': '${data['category'] ?? 'Meal'} • ${data['calories'] ?? 0} cal',
              'members': '${(data['protein'] ?? 0).toString()} protein',
              'calories': data['calories'] ?? 0,
              'category': data['category'] ?? 'Meal',
            };
          }).toList();
        });
        await _cacheData();
      }
    } catch (e) {
      throw Exception('Failed to fetch meal plans: $e');
    }
  }

  Future<void> _fetchTodaysChallenge() async {
    try {
      final snapshot = await _firestore.collection('challenges')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _todaysChallenge = {
            'id': doc.id,
            'title': data['title'] ?? 'Challenge',
            'imageUrl': data['imageUrl'] ?? '',
            'duration': '${data['duration'] ?? 0} min',
            'description': data['description'] ?? 'No description',
            'points': data['points'] ?? 0,
          };
        });
        await _cacheData();
      }
    } catch (e) {
      throw Exception('Failed to fetch challenge: $e');
    }
  }

  void _initializeVideoControllers() {
    _exerciseControllers = _quickExercises.map((exercise) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(exercise['videoUrl']),
      )..initialize().then((_) {
          if (mounted) setState(() {});
        });
      return controller;
    }).toList();
  }

  void _initializeGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        greeting = 'Good Morning';
      } else if (hour < 17) {
        greeting = 'Good Afternoon';
      } else {
        greeting = 'Good Evening';
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users_fitguy').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc.data()?['fullName'] ?? 'User';
          });
        }
      }
    } catch (e) {
      // Use cached data if available
      final cachedName = await _getCachedUserName();
      setState(() {
        userName = cachedName ?? 'User';
      });
    }
  }

  Future<String?> _getCachedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cachedUserName');
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
    
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
      if (isConnected && _errorMessage != null) {
        // Retry fetching data when connection is restored
        _fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          List<ConnectivityResult> connectivityResults,
          Widget child,
        ) {
          final bool connected = connectivityResults.isNotEmpty &&
              connectivityResults.first != ConnectivityResult.none;
          if (connected != isConnected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                isConnected = connected;
              });
            });
          }
          return child;
        },
        child: _isLoading
            ? _buildLoadingIndicator()
            : _errorMessage != null && _quickExercises.isEmpty
                ? _buildErrorView()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isConnected) _buildOfflineBanner(),
                        if (_errorMessage != null) _buildErrorBanner(),
                        _buildSearchSection(),
                        const SizedBox(height: 25),
                        if (_todaysChallenge != null) _buildTodaysPlan(context),
                        const SizedBox(height: 25),
                        if (_quickExercises.isNotEmpty) _buildGetStarted(context),
                        const SizedBox(height: 25),
                        if (_recommendedPlans.isNotEmpty) _buildRecommendedPlans(context),
                        const SizedBox(height: 25),
                        _buildActivitySection(),
                        const SizedBox(height: 25),
                        _buildLowerBodyTraining(),
                      ],
                    )),
                  ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 20),
          Text(
            'Loading your fitness data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? 'Error loading some data',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: _fetchAllData,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 18, color: Colors.amber),
          const SizedBox(width: 8),
          const Text(
            'Offline Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _checkConnectivity(),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            userName ?? 'Loading...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: _auth.currentUser?.photoURL ?? 'https://www.gravatar.com/avatar/default?s=200',
                placeholder: (context, url) => const Icon(Icons.person, size: 20),
                errorWidget: (context, url, error) => const Icon(Icons.person, size: 20),
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find Your Workout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search workouts...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCategoryIndex == index
                        ? Colors.deepPurple
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedCategoryIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysPlan(BuildContext context) {
    final challenge = _todaysChallenge!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/workout-detail', arguments: {
              'title': challenge['title'],
              'image': challenge['imageUrl'],
              'time': challenge['duration'],
              'points': challenge['points'],
              'description': challenge['description'],
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      challenge['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TOP PICK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: 0.2,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.white,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '20% completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${challenge['duration']} • ${challenge['points']} pts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGetStarted(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Exercises',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _quickExercises.length >= 2
            ? Row(
                children: [
                  _buildExerciseVideoCard(context, 0),
                  const SizedBox(width: 15),
                  _buildExerciseVideoCard(context, 1),
                ],
              )
            : _quickExercises.isNotEmpty
                ? _buildExerciseVideoCard(context, 0)
                : const Text('No quick exercises available'),
      ],
    );
  }

  Widget _buildExerciseVideoCard(BuildContext context, int index) {
    if (index >= _quickExercises.length || index >= _exerciseControllers.length) {
      return const SizedBox.shrink();
    }

    final exercise = _quickExercises[index];
    final controller = _exerciseControllers[index];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailsScreen(
                title: exercise['title'],
                videoPath: exercise['videoUrl'],
                time: exercise['duration'],
                level: exercise['level'],
                description: exercise['description'],
              ),
            ),
          );
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (controller.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${exercise['level']} • ${exercise['duration']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 48,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedPlans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended Plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealPlansScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final plan in _recommendedPlans)
                _buildPlanCard(
                  plan['title'],
                  plan['imageUrl'],
                  plan['subtitle'],
                  plan['members'],
                ),
              if (_recommendedPlans.isEmpty)
                const SizedBox(
                  width: 200,
                  child: Center(child: Text('No recommended plans')),
          )],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
      String title, String? imageUrl, String subtitle, String members) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        members,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      const Text(
                        '4.8',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildActivityProgress('Workouts Completed', 0.7, '7/10'),
          _buildActivityProgress('Calories Burned', 0.5, '1,200/2,400'),
          _buildActivityProgress('Weekly Goal', 0.9, '4/5 days'),
        ],
      ),
    );
  }

  Widget _buildActivityProgress(String title, double progress, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: Colors.deepPurple,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildLowerBodyTraining() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lower Body Focus',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Target your legs and glutes with these specialized workouts designed to build strength and endurance in your lower body.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(Icons.timer, '30 min', 'Workout Time'),
              _buildStatCard(Icons.local_fire_department, '250 cal', 'Avg Burn'),
              _buildStatCard(Icons.emoji_events, 'Beginner', 'Level'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  WorkoutsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Start Training',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}